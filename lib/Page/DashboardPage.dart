import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'FloorPage.dart';
import 'RoomPage.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // ✅ Dialog ជ្រើសជាន់ → ទាញទិន្នន័យពី Firestore ផ្ទាល់ និងបញ្ជូនទៅ RoomPage
  void _showSelectFloorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ជ្រើសរើសជាន់"),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('floors').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF27AE60)));
              }

              final floors = snapshot.data?.docs ?? [];

              if (floors.isEmpty) {
                return const Text("មិនទាន់មានជាន់ទេ!\nសូមបន្ថែមជាន់មុន។");
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: floors.length,
                itemBuilder: (context, index) {
                  final floorData = floors[index].data() as Map<String, dynamic>?;
                  final floorTitle = floorData?['name'] ?? floorData?['title'] ?? "ជាន់ទី ${floorData?['floorNumber'] ?? (index + 1)}";
                  final roomCountText = "${floorData?['roomCount'] ?? 0} បន្ទប់";

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
                    title: Text(floorTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(roomCountText,
                        style: const TextStyle(color: Colors.grey)),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 14, color: Colors.grey),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoomPage(
                            floorTitle: floorTitle, // ✅ បញ្ជូនទៅកាន់ RoomPage
                          ),
                        ),
                      );
                    },
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
      // 🔹 ប្រើ Nested StreamBuilder ដើម្បីទាញយកទាំង Floors និង Tenants ពី Firestore
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('floors').snapshots(),
        builder: (context, floorSnapshot) {
          final floorDocs = floorSnapshot.data?.docs ?? [];
          final totalFloors = floorDocs.length;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('tenants').snapshots(),
            builder: (context, tenantSnapshot) {
              if (floorSnapshot.connectionState == ConnectionState.waiting ||
                  tenantSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF27AE60)));
              }

              final tenantDocs = tenantSnapshot.data?.docs ?? [];
              final totalTenants = tenantDocs.length;

              // គណនាចំណូលប្រចាំខែ
              double monthlyRevenue = 0.0;
              final occupiedRoomsSet = <String>{};

              for (var doc in tenantDocs) {
                final data = doc.data() as Map<String, dynamic>?;
                if (data != null) {
                  final rent = (data['rent'] as num?)?.toDouble() ?? 0.0;
                  final isPaid = data['paymentStatus'] == 'paid';
                  final roomNumber = data['roomNumber'] ?? '';

                  if (isPaid) {
                    monthlyRevenue += rent;
                  }
                  if (roomNumber.toString().isNotEmpty) {
                    occupiedRoomsSet.add(roomNumber.toString());
                  }
                }
              }

              final occupiedRoomsCount = occupiedRoomsSet.length;
              final totalRooms = totalFloors * 10; // សន្មត ១ជាន់មាន ១០បន្ទប់
              final vacantRoomsCount = totalRooms - occupiedRoomsCount;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        _buildCard("ជាន់សរុប", totalFloors.toString().padLeft(2, '0'),
                            Icons.door_sliding_outlined, Colors.green),
                        _buildCard("បន្ទប់ទំនេរ", vacantRoomsCount.clamp(0, 99).toString().padLeft(2, '0'),
                            Icons.door_back_door_outlined, Colors.green),
                        _buildCard("បន្ទប់មានមនុស្ស", occupiedRoomsCount.toString().padLeft(2, '0'),
                            Icons.bed_outlined, Colors.green),
                        _buildCard("អ្នកជួលសរុប", totalTenants.toString().padLeft(2, '0'),
                            Icons.people_outline, Colors.green),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text("ទិដ្ឋភាពទូទៅនៃចំណូលប្រចាំខែ",
                        style: TextStyle(fontSize: 18, fontFamily: 'Fasthand',)),
                    const SizedBox(height: 10),
                    _buildRevenueKPICard(monthlyRevenue),
                    const SizedBox(height: 20),
                    const Text("សកម្មភាពរហ័ស",
                        style: TextStyle(fontSize: 18, fontFamily: 'Fasthand',)),
                    const SizedBox(height: 10),
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
                    _buildActionButton(
                      context: context,
                      title: "បន្ថែមបន្ទប់",
                      icon: Icons.home_outlined,
                      onTap: () => _showSelectFloorDialog(context),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRevenueKPICard(double revenue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF27AE60), Color(0xFF11998E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF27AE60).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ចំណូលខែនេះ (បានបង់រួច)",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  "\$${revenue.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.trending_up_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        "+12% ធៀបនឹងខែមុន",
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String count, IconData icon, Color color) {
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
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
