import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'RoomPage.dart';

class Floor {
  final String id;
  String title;

  Floor({required this.id, required this.title});
}

class FloorPage extends StatefulWidget {
  final VoidCallback onBackToDashboard;
  const FloorPage({super.key, required this.onBackToDashboard});

  @override
  State<FloorPage> createState() => _FloorPageState();
}

class _FloorPageState extends State<FloorPage> {
  String searchQuery = "";

  void _showAddFloorDialog() {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("បន្ថែមជាន់ថ្មី", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: "ឈ្មោះជាន់",
            hintText: "ឧ: ជាន់ទី១",
            prefixIcon: const Icon(Icons.layers_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("បោះបង់", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27AE60)),
            onPressed: () {
              if (titleController.text.isEmpty) return;

              FirebaseFirestore.instance.collection('floors').add({
                'title': titleController.text,
                'createdAt': FieldValue.serverTimestamp(),
              });

              Navigator.pop(context);
            },
            child: const Text("រក្សាទុក", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ៣. Dialog កែប្រែឈ្មោះជាន់
  void _showEditFloorDialog(Floor floor) {
    final titleController = TextEditingController(text: floor.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("កែប្រែជាន់"),
        content: TextField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: "ឈ្មោះជាន់",
            prefixIcon: const Icon(Icons.layers_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("បោះបង់", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27AE60)),
            onPressed: () {
              if (titleController.text.isEmpty) return;

              FirebaseFirestore.instance.collection('floors').doc(floor.id).update({
                'title': titleController.text,
              });

              Navigator.pop(context);
            },
            child: const Text("រក្សាទុក", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Floor floor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("លុបជាន់"),
        content: Text("តើអ្នកប្រាកដជាចង់លុប \"${floor.title}\" មែនទេ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("បោះបង់")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              FirebaseFirestore.instance.collection('floors').doc(floor.id).delete();
              Navigator.pop(context);
            },
            child: const Text("លុប", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(Floor floor) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.layers_outlined, color: Colors.grey),
                  const SizedBox(width: 10),
                  Text(floor.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text("កែប្រែ"),
              onTap: () {
                Navigator.pop(context);
                _showEditFloorDialog(floor);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("លុប", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(floor);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF27AE60),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: widget.onBackToDashboard,
        ),
        title: const Text("ជាន់", style: TextStyle(color: Colors.black,fontFamily: 'Fasthand',)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFloorDialog,
        backgroundColor: const Color(0xFF27AE60),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: "ស្វែងរកតាមឈ្មោះជាន់",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('floors').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("មានបញ្ហាក្នុងការទាញទិន្នន័យ"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final floors = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Floor(
                    id: doc.id,
                    title: data['title'] ?? '',
                  );
                }).toList();

                final filteredFloors = searchQuery.isEmpty
                    ? floors
                    : floors.where((f) => f.title.toLowerCase().contains(searchQuery.toLowerCase())).toList();

                if (filteredFloors.isEmpty) {
                  return const Center(child: Text("មិនមានជាន់ដែលអ្នកស្វែងរកទេ"));
                }

                return ListView.builder(
                  itemCount: filteredFloors.length,
                  itemBuilder: (context, index) => _buildFloorItem(filteredFloors[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorItem(Floor floor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 15, right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RoomPage(floorTitle: floor.title)),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.layers_outlined, color: Colors.black),
        ),
        title: Text(floor.title, style: const TextStyle(fontWeight: FontWeight.bold)),

        subtitle: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('rooms')
              .where('floor', isEqualTo: floor.title)
              .snapshots(),
          builder: (context, roomSnapshot) {
            if (!roomSnapshot.hasData) return const Text("កំពុងគណនា...", style: TextStyle(color: Colors.grey, fontSize: 12));
            final roomCount = roomSnapshot.data!.docs.length;
            return Text("$roomCount បន្ទប់", style: const TextStyle(color: Colors.grey));
          },
        ),
        trailing: SizedBox(
          width: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _showOptionsMenu(floor),
                child: const Icon(Icons.more_vert, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
