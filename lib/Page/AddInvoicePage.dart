import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'RoomPage.dart';

class AddInvoicePage extends StatefulWidget {
  final List<Room> rooms;
  const AddInvoicePage({super.key, required this.rooms});

  @override
  State<AddInvoicePage> createState() => _AddInvoicePageState();
}

class _AddInvoicePageState extends State<AddInvoicePage> {
  Room? selectedRoom;
  final electricController = TextEditingController();
  final waterController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<Room> busyRooms = widget.rooms.where((r) => r.status == "busy").toList();

    return Scaffold(
      appBar: AppBar(title: const Text("បង្កើតវិក្កយបត្រ"), backgroundColor: const Color(0xFF27AE60)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<Room>(
              decoration: const InputDecoration(labelText: "ជ្រើសរើសបន្ទប់", border: OutlineInputBorder()),
              value: selectedRoom,
              items: busyRooms.map((room) {
                return DropdownMenuItem(value: room, child: Text("បន្ទប់ ${room.roomNumber} - ${room.tenantName}"));
              }).toList(),
              onChanged: (val) => setState(() => selectedRoom = val),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: electricController,
              decoration: const InputDecoration(labelText: "អគ្គិសនីប្រើប្រាស់ (យូនីត)", prefixIcon: Icon(Icons.electric_bolt, color: Colors.orange)),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: waterController,
              decoration: const InputDecoration(labelText: "ទឹកប្រើប្រាស់ (គូប)", prefixIcon: Icon(Icons.water_drop, color: Colors.blue)),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: const Color(0xFF27AE60)),
              onPressed: () async {
                if (selectedRoom != null) {
                  // ១. ទាញយកតម្លៃកំណត់ទឹកភ្លើងប្រចាំខែពី Firebase settings
                  final priceSnap = await FirebaseFirestore.instance.collection('settings').doc('invoice_prices').get();
                  final priceData = priceSnap.data();
                  final ePrice = double.tryParse(priceData?['price_electricity']?.toString() ?? '700') ?? 700.0;
                  final wPrice = double.tryParse(priceData?['price_water']?.toString() ?? '2000') ?? 2000.0;
                  final wifiPrice = double.tryParse(priceData?['price_wifi']?.toString() ?? '10') ?? 10.0;

                  final electricityUnits = double.tryParse(electricController.text) ?? 0.0;
                  final waterUnits = double.tryParse(waterController.text) ?? 0.0;

                  // ២. គណនាទឹកប្រាក់សរុបប្រចាំខែ (ឧបមាថា $1 = 4000៛)
                  final totalAmount = selectedRoom!.rent +
                      ((electricityUnits * ePrice) / 4000) +
                      ((waterUnits * wPrice) / 4000) +
                      wifiPrice;

                  final currentMonth = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}";

                  // ៣. រក្សាទុកទិន្នន័យពេញលេញទៅកាន់ Firestore
                  await FirebaseFirestore.instance.collection('payments').add({
                    'tenantName': selectedRoom!.tenantName,
                    'roomId': selectedRoom!.roomNumber,
                    'floor': "ជាន់បច្ចុប្បន្ន",
                    'phone': selectedRoom!.phone,
                    'rent': selectedRoom!.rent,
                    'electricity': electricityUnits,
                    'water': waterUnits,
                    'wifi': wifiPrice,
                    'status': 'unpaid',
                    'avatarColor': 4283215696,
                    'billingMonth': currentMonth,
                    'total_amount': double.parse(totalAmount.toStringAsFixed(2)), // រក្សាទុកការគណនាសរុបស្វ័យប្រវត្ត
                  });

                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text("យល់ព្រមបង្កើត", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
