import 'package:flutter/material.dart';
import 'MonthlyInvoicePage.dart';
import 'RoomPage.dart';

class AddInvoicePage extends StatefulWidget {
  final List<Room> rooms; // ទទួលបញ្ជីបន្ទប់ពី RoomPage

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
    // ចម្រាញ់យកតែបន្ទប់ណាដែលមានអ្នកជួល (Busy)
    List<Room> busyRooms = widget.rooms.where((r) => r.status == "busy").toList();

    return Scaffold(
      appBar: AppBar(title: const Text("បង្កើតវិក្កយបត្រ"), backgroundColor: const Color(0xFF27AE60)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // រើសបន្ទប់
            DropdownButtonFormField<Room>(
              decoration: const InputDecoration(labelText: "ជ្រើសរើសបន្ទប់", border: OutlineInputBorder()),
              value: selectedRoom,
              items: busyRooms.map((room) {
                return DropdownMenuItem(value: room, child: Text("បន្ទប់ ${room.roomNumber} - ${room.tenantName}"));
              }).toList(),
              onChanged: (val) => setState(() => selectedRoom = val),
            ),
            const SizedBox(height: 16),

            // បញ្ចូលលេខកុងទ័រ
            TextField(
              controller: electricController,
              decoration: const InputDecoration(labelText: "អគ្គិសនី (សរុបរៀល)", prefixIcon: Icon(Icons.electric_bolt, color: Colors.orange)),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: waterController,
              decoration: const InputDecoration(labelText: "ទឹក (សរុបរៀល)", prefixIcon: Icon(Icons.water_drop, color: Colors.blue)),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: const Color(0xFF27AE60)),
              onPressed: () {
                if (selectedRoom != null) {
                  // បង្កើត Object Invoice ថ្មី
                  final newInvoice = Invoice(
                    tenantName: selectedRoom!.tenantName,
                    roomNumber: selectedRoom!.roomNumber,
                    floor: "ជាន់បច្ចុប្បន្ន",
                    phone: selectedRoom!.phone,
                    rent: selectedRoom!.rent,
                    electricity: double.tryParse(electricController.text) ?? 0,
                    water: double.tryParse(waterController.text) ?? 0,
                    wifi: 10, // តម្លៃ Default
                    paymentStatus: "unpaid",
                    avatarColor: Colors.blue,
                  );
                  Navigator.pop(context, newInvoice);
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