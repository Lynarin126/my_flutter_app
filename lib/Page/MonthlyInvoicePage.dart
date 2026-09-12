import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Invoice {
  final String id;
  String tenantName, roomNumber, floor, phone, paymentStatus;
  double rent, electricity, water, wifi;
  final Color avatarColor;

  Invoice({required this.id, required this.tenantName, required this.roomNumber, required this.floor, required this.phone, required this.rent, required this.electricity, required this.water, required this.wifi, required this.paymentStatus, required this.avatarColor});

  double getTotal(double eP, double wP) => rent + ((electricity * eP) / 4000) + ((water * wP) / 4000) + wifi;

  factory Invoice.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>?;
    return Invoice(
      id: doc.id,
      tenantName: d?['tenantName'] ?? d?['name'] ?? 'No Name',
      roomNumber: d?['roomId'] ?? d?['roomNumber'] ?? '',
      floor: d?['floor'] ?? '',
      phone: d?['phone'] ?? '',
      rent: (d?['rent'] as num?)?.toDouble() ?? 0.0,
      electricity: (d?['electricity'] as num?)?.toDouble() ?? 0.0,
      water: (d?['water'] as num?)?.toDouble() ?? 0.0,
      wifi: (d?['wifi'] as num?)?.toDouble() ?? 10.0,
      paymentStatus: d?['status'] ?? d?['paymentStatus'] ?? 'unpaid',
      avatarColor: Color(d?['avatarColor'] ?? 4283215696),
    );
  }
}

class MonthlyInvoicePage extends StatefulWidget {
  const MonthlyInvoicePage({super.key});
  @override
  State<MonthlyInvoicePage> createState() => _MonthlyInvoicePageState();
}

class _MonthlyInvoicePageState extends State<MonthlyInvoicePage> {
  double electricityPrice = 700, waterPrice = 2000;
  String selectedFilter = "ទាំងអស់";
  final _db = FirebaseFirestore.instance.collection('payments');
  StreamSubscription? _priceSub;

  @override
  void initState() {
    super.initState();
    _priceSub = FirebaseFirestore.instance.collection('settings').doc('invoice_prices').snapshots().listen((snap) {
      if (mounted && snap.exists) {
        final d = snap.data();
        setState(() {
          electricityPrice = double.tryParse(d?['price_electricity']?.toString() ?? '700') ?? 700;
          waterPrice = double.tryParse(d?['price_water']?.toString() ?? '2000') ?? 2000;
        });
      }
    });
  }

  @override
  void dispose() { _priceSub?.cancel(); super.dispose(); }

  void _showInvoiceDetail(Invoice inv) {
    final eCtrl = TextEditingController(text: inv.electricity.toString());
    final wCtrl = TextEditingController(text: inv.water.toString());
    final rCtrl = TextEditingController(text: inv.rent.toString());
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (c) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text("កែប្រែវិក្កយបត្រ - Room ${inv.roomNumber}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            TextField(controller: eCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "អគ្គិសនី", prefixIcon: Icon(Icons.electric_bolt))),
            TextField(controller: wCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "ទឹក", prefixIcon: Icon(Icons.water_drop))),
            TextField(controller: rCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "តម្លៃជួល", prefixIcon: Icon(Icons.home))),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: inv.paymentStatus == "paid" ? Colors.orange : Colors.green),
                onPressed: () { _db.doc(inv.id).update({'status': inv.paymentStatus == "paid" ? "unpaid" : "paid"}); Navigator.pop(c); },
                child: Text(inv.paymentStatus == "paid" ? "មិនទាន់បង់" : "យល់ព្រមបង់ប្រាក់", style: const TextStyle(color: Colors.white)),
              )),
              IconButton(onPressed: () {
                _db.doc(inv.id).update({
                  'electricity': double.tryParse(eCtrl.text) ?? 0,
                  'water': double.tryParse(wCtrl.text) ?? 0,
                  'rent': double.tryParse(rCtrl.text) ?? 0,
                  'total_amount': (double.tryParse(rCtrl.text) ?? 0) + (((double.tryParse(eCtrl.text) ?? 0) * electricityPrice)/4000) + (((double.tryParse(wCtrl.text) ?? 0) * waterPrice)/4000) + inv.wifi
                });
                Navigator.pop(c);
              }, icon: const Icon(Icons.save, color: Colors.blue)),
              IconButton(onPressed: () { _db.doc(inv.id).delete(); Navigator.pop(c); }, icon: const Icon(Icons.delete, color: Colors.red)),
            ]),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("គ្រប់គ្រងវិក្កយបត្រ", style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF27AE60)),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final list = snap.data!.docs.map((d) => Invoice.fromDoc(d)).toList();
          final paid = list.where((i) => i.paymentStatus == "paid").fold(0.0, (sum, i) => sum + i.getTotal(electricityPrice, waterPrice));
          final unpaid = list.where((i) => i.paymentStatus == "unpaid").fold(0.0, (sum, i) => sum + i.getTotal(electricityPrice, waterPrice));
          final filtered = list.where((i) {
            if (selectedFilter == "បានបង់") return i.paymentStatus == "paid";
            if (selectedFilter == "មិនទាន់បង់") return i.paymentStatus == "unpaid";
            return true;
          }).toList();
          return Column(children: [
            Container(
              padding: const EdgeInsets.all(20), color: const Color(0xFF27AE60),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _stat("បានបង់", "\$${paid.toStringAsFixed(2)}", Icons.check_circle),
                _stat("ជំពាក់", "\$${unpaid.toStringAsFixed(2)}", Icons.info),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: ["ទាំងអស់", "បានបង់", "មិនទាន់បង់"].map((f) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ChoiceChip(label: Text(f), selected: selectedFilter == f, onSelected: (v) => setState(() => selectedFilter = f)),
              )).toList()),
            ),
            Expanded(child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (c, i) {
                final inv = filtered[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    onTap: () => _showInvoiceDetail(inv),
                    leading: CircleAvatar(backgroundColor: inv.avatarColor, child: Text(inv.tenantName.isNotEmpty ? inv.tenantName[0] : "?")),
                    title: Text(inv.tenantName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Room ${inv.roomNumber} • Total: \$${inv.getTotal(electricityPrice, waterPrice).toStringAsFixed(2)}"),
                    trailing: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: inv.paymentStatus == "paid" ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(inv.paymentStatus == "paid" ? "Paid" : "Unpaid", style: TextStyle(color: inv.paymentStatus == "paid" ? Colors.green : Colors.red, fontSize: 12)),
                    ),
                  ),
                );
              },
            )),
          ]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF27AE60),
        onPressed: () => _db.add({'tenantName': 'អ្នកជួលថ្មី', 'roomId': 'NEW', 'floor': 'ជាន់ទី១', 'phone': '', 'rent': 100, 'electricity': 0, 'water': 0, 'wifi': 10, 'status': 'unpaid', 'avatarColor': 4283215696, 'billingMonth': '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2,'0')}'}),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _stat(String l, String v, IconData i) => Column(children: [
    Icon(i, color: Colors.white70),
    Text(l, style: const TextStyle(color: Colors.white70)),
    Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
  ]);
}
