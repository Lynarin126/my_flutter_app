import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================
// Invoice Model
// ============================
class Invoice {
  String tenantName;
  String roomNumber;
  String floor;
  String phone;
  double rent;
  double electricity; // ចំនួនយូនីត
  double water;       // ចំនួនគូប
  double wifi;
  String paymentStatus;
  final Color avatarColor;

  Invoice({
    required this.tenantName,
    required this.roomNumber,
    required this.floor,
    required this.phone,
    required this.rent,
    required this.electricity,
    required this.water,
    required this.wifi,
    required this.paymentStatus,
    required this.avatarColor,
  });

  // គណនាសរុប (ឧបមាថា $1 = 4000៛)
  double getTotal(double ePrice, double wPrice) {
    return rent + ((electricity * ePrice) / 4000) + ((water * wPrice) / 4000) + wifi;
  }
}

class MonthlyInvoicePage extends StatefulWidget {
  const MonthlyInvoicePage({super.key});

  @override
  State<MonthlyInvoicePage> createState() => _MonthlyInvoicePageState();
}

class _MonthlyInvoicePageState extends State<MonthlyInvoicePage> {
  double electricityPrice = 700;
  double waterPrice = 2000;
  String selectedFilter = "ទាំងអស់";

  // បញ្ជីទិន្នន័យ (Static List)
  List<Invoice> invoices = [
    Invoice(tenantName: "Narin", roomNumber: "004", floor: "ជាន់ ទី៦", phone: "012345678", rent: 150, electricity: 10, water: 5, wifi: 10, paymentStatus: "unpaid", avatarColor: Colors.red),
    Invoice(tenantName: "Reach", roomNumber: "001", floor: "ជាន់ ទី៦", phone: "0887654321", rent: 120, electricity: 20, water: 2, wifi: 10, paymentStatus: "paid", avatarColor: Colors.green),
  ];

  // --- Logic សម្រាប់សរុបលុយ ---
  double get _totalPaid => invoices.where((i) => i.paymentStatus == "paid").fold(0, (sum, i) => sum + i.getTotal(electricityPrice, waterPrice));
  double get _totalUnpaid => invoices.where((i) => i.paymentStatus == "unpaid").fold(0, (sum, i) => sum + i.getTotal(electricityPrice, waterPrice));

  // --- មុខងារ Delete ---
  void _deleteInvoice(int index) {
    setState(() {
      invoices.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("បានលុបវិក្កយបត្ររួចរាល់")));
  }

  // --- មុខងារ View/Edit (ប្រើ Dialog ចាស់របស់អ្នកតែ Upgrade) ---
  void _showInvoiceDetail(int index) {
    final invoice = invoices[index];
    final elecController = TextEditingController(text: invoice.electricity.toString());
    final waterController = TextEditingController(text: invoice.water.toString());
    final rentController = TextEditingController(text: invoice.rent.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("កែប្រែវិក្កយបត្រ - Room ${invoice.roomNumber}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Divider(),
                _buildInput(elecController, "ចំនួនអគ្គិសនី (យូនីត)", Icons.electric_bolt, Colors.orange),
                _buildInput(waterController, "ចំនួនទឹក (គូប)", Icons.water_drop, Colors.blue),
                _buildInput(rentController, "តម្លៃជួល (\$)", Icons.home, Colors.green),
                const SizedBox(height: 20),

                Row(
                  children: [
                    // ប៊ូតុងបង់ប្រាក់ (Add Payment Feature)
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: invoice.paymentStatus == "paid" ? Colors.orange : Colors.green),
                        onPressed: () {
                          setState(() {
                            invoice.paymentStatus = (invoice.paymentStatus == "paid") ? "unpaid" : "paid";
                          });
                          Navigator.pop(context);
                        },
                        child: Text(invoice.paymentStatus == "paid" ? "កំណត់ថាមិនទាន់បង់" : "យល់ព្រមបង់ប្រាក់", style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // ប៊ូតុងរក្សាទុកការកែប្រែ
                    IconButton(
                      onPressed: () {
                        setState(() {
                          invoice.electricity = double.tryParse(elecController.text) ?? 0;
                          invoice.water = double.tryParse(waterController.text) ?? 0;
                          invoice.rent = double.tryParse(rentController.text) ?? 0;
                        });
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.save, color: Colors.blue, size: 30),
                    ),
                    // ប៊ូតុងលុប
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteInvoice(index);
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 30),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, Color color) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: color)),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Invoice> displayList = invoices.where((i) {
      if (selectedFilter == "បានបង់") return i.paymentStatus == "paid";
      if (selectedFilter == "មិនទាន់បង់") return i.paymentStatus == "unpaid";
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("គ្រប់គ្រងវិក្កយបត្រ", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF27AE60),
      ),
      body: Column(
        children: [
          // បង្ហាញសរុបលុយ (UI ចាស់របស់អ្នក)
          _buildSummaryHeader(),

          // Filter Chips
          _buildFilterChips(),

          // បញ្ជីវិក្កយបត្រ
          Expanded(
            child: ListView.builder(
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final inv = displayList[index];
                return _buildInvoiceItem(inv, index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF27AE60),
        onPressed: () {
          // Logic សម្រាប់ Add ថ្មី (Static)
          setState(() {
            invoices.add(Invoice(
                tenantName: "អ្នកជួលថ្មី", roomNumber: "NEW", floor: "ជាន់ទី១", phone: "000",
                rent: 100, electricity: 0, water: 0, wifi: 10, paymentStatus: "unpaid", avatarColor: Colors.blueGrey
            ));
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- UI Components (ដកស្រង់ពី Design ស្អាតៗរបស់អ្នក) ---

  Widget _buildSummaryHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFF27AE60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("បានបង់រួច", "\$${_totalPaid.toStringAsFixed(2)}", Icons.check_circle),
          _statItem("ជំពាក់", "\$${_totalUnpaid.toStringAsFixed(2)}", Icons.info),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70),
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ["ទាំងអស់", "បានបង់", "មិនទាន់បង់"].map((f) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: ChoiceChip(
            label: Text(f),
            selected: selectedFilter == f,
            onSelected: (val) => setState(() => selectedFilter = f),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildInvoiceItem(Invoice inv, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: () => _showInvoiceDetail(index), // ចុចដើម្បី View/Edit/Delete/Pay
        leading: CircleAvatar(backgroundColor: inv.avatarColor, child: Text(inv.tenantName[0], style: const TextStyle(color: Colors.white))),
        title: Text(inv.tenantName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Room ${inv.roomNumber} • Total: \$${inv.getTotal(electricityPrice, waterPrice).toStringAsFixed(2)}"),
        trailing: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: inv.paymentStatus == "paid" ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)
          ),
          child: Text(inv.paymentStatus == "paid" ? "Paid" : "Unpaid", style: TextStyle(color: inv.paymentStatus == "paid" ? Colors.green : Colors.red, fontSize: 12)),
        ),
      ),
    );
  }
}