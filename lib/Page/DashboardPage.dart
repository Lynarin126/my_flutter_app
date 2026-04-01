import 'package:flutter/material.dart';
import 'FloorPage.dart';
import 'RoomPage.dart';
import 'floor_data.dart'; // ✅ Import ថ្មី

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // ✅ Dialog ជ្រើសជាន់ → Navigate ទៅ RoomPage
  void _showSelectFloorDialog(BuildContext context) {
    final floors = FloorData().floors; // ✅ ទាញ List ជាន់ពី Shared Data

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ជ្រើសរើសជាន់"),
        content: SizedBox(
          width: double.maxFinite,
          child: floors.isEmpty
              ? const Text("មិនទាន់មានជាន់ទេ!\nសូមបន្ថែមជាន់មុន។")
              : ListView.builder(
            shrinkWrap: true,
            itemCount: floors.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.layers_outlined,
                      color: Color(0xFF27AE60)),
                ),
                title: Text(floors[index].title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),
                subtitle: Text(floors[index].roomCount,
                    style: const TextStyle(color: Colors.grey)),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey),
                // ✅ ជ្រើសជាន់ → Navigate ទៅ RoomPage
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoomPage(
                        floorTitle: floors[index].title,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("បោះបង់",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2EB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grid ៤ ប្រអប់
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildCard("ជាន់សរុប", "០៦",
                    Icons.door_sliding_outlined, Colors.green),
                _buildCard("បន្ទប់ទំនេរ", "០៤",
                    Icons.door_back_door_outlined, Colors.green),
                _buildCard("បន្ទប់មានមនុស្ស", "០៥",
                    Icons.bed_outlined, Colors.green),
                _buildCard("អ្នកជួលសរុប", "០៥",
                    Icons.people_outline, Colors.green),
              ],
            ),

            const SizedBox(height: 20),

            // ក្រាហ្វិក
            const Text("ទិដ្ឋភាពទូទៅនៃចំណូលប្រចាំខែ",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              height: 200,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.brown.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("ចំណូលខែនេះ:",
                      style: TextStyle(color: Colors.grey)),
                  const Text("\$0.00",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Aug", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text("Sep", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text("Oct", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text("Nov", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text("Jan", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Quick Actions
            const Text("សកម្មភាពរហ័ស",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // ✅ Button បន្ថែមជាន់ → FloorPage
            _buildActionButton(
              context: context,
              title: "បន្ថែមជាន់",
              icon: Icons.assignment_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FloorPage(
                    onBackToDashboard: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ✅ Button បន្ថែមបន្ទប់ → Dialog ជ្រើសជាន់ → RoomPage
            _buildActionButton(
              context: context,
              title: "បន្ថែមបន្ទប់",
              icon: Icons.home_outlined,
              onTap: () => _showSelectFloorDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              Text(count,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF27AE60),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 15),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}