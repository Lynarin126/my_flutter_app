import 'package:flutter/material.dart';
import 'RoomPage.dart';
import 'floor_data.dart'; // ✅ Import ថ្មី



class FloorPage extends StatefulWidget {
  final VoidCallback onBackToDashboard;
  const FloorPage({super.key, required this.onBackToDashboard});

  @override
  State<FloorPage> createState() => _FloorPageState();
}

class _FloorPageState extends State<FloorPage> {
  String searchQuery = "";

  // ✅ ប្រើ FloorData() ជំនួស List floors ចាស់
  final floorData = FloorData();

  List<Floor> get _filteredFloors {
    if (searchQuery.isEmpty) return floorData.floors;
    return floorData.floors
        .where((f) => f.title.toLowerCase()
        .contains(searchQuery.toLowerCase()))
        .toList();
  }

  void _showAddFloorDialog() {
    final titleController = TextEditingController();
    final roomCountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("បន្ថែមជាន់ថ្មី"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "ឈ្មោះជាន់",
                hintText: "ឧ: ជាន់ ទី១២",
                prefixIcon: const Icon(Icons.layers_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: roomCountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "ចំនួនបន្ទប់",
                hintText: "ឧ: 5",
                prefixIcon: const Icon(Icons.door_front_door_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("បោះបង់",
                style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60)),
            onPressed: () {
              if (titleController.text.isEmpty ||
                  roomCountController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("សូមបំពេញព័ត៌មានឱ្យបានគ្រប់!")),
                );
                return;
              }
              // ✅ Add ទៅ floorData.floors
              setState(() {
                floorData.floors.add(Floor(
                  title: titleController.text,
                  roomCount: "${roomCountController.text} បន្ទប់",
                ));
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("បានបន្ថែមជាន់ដោយជោគជ័យ!"),
                  backgroundColor: Color(0xFF27AE60),
                ),
              );
            },
            child: const Text("រក្សាទុក",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditFloorDialog(Floor floor) {
    final titleController = TextEditingController(text: floor.title);
    final roomCountController = TextEditingController(
      text: floor.roomCount.replaceAll(" បន្ទប់", ""),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("កែប្រែជាន់"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "ឈ្មោះជាន់",
                prefixIcon: const Icon(Icons.layers_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: roomCountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "ចំនួនបន្ទប់",
                prefixIcon: const Icon(Icons.door_front_door_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("បោះបង់",
                style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60)),
            onPressed: () {
              if (titleController.text.isEmpty ||
                  roomCountController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("សូមបំពេញព័ត៌មានឱ្យបានគ្រប់!")),
                );
                return;
              }
              setState(() {
                floor.title = titleController.text;
                floor.roomCount =
                "${roomCountController.text} បន្ទប់";
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("បានកែប្រែជាន់ដោយជោគជ័យ!"),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text("រក្សាទុក",
                style: TextStyle(color: Colors.white)),
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
        content: Text(
            "តើអ្នកប្រាកដជាចង់លុប \"${floor.title}\" មែនទេ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("បោះបង់"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () {
              // ✅ លុបពី floorData.floors
              setState(() => floorData.floors.remove(floor));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                  Text("បានលុប \"${floor.title}\" រួចហើយ!"),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text("លុប",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(Floor floor) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.layers_outlined, color: Colors.grey),
                  const SizedBox(width: 10),
                  Text(floor.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
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
              title: const Text("លុប",
                  style: TextStyle(color: Colors.red)),
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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.black, size: 28),
          onPressed: widget.onBackToDashboard,
        ),
        title: const Text("ជាន់",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
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
              onChanged: (value) =>
                  setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: "ស្វែងរកតាមឈ្មោះជាន់",
                prefixIcon:
                const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                  BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                  BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredFloors.isEmpty
                ? const Center(
                child: Text("មិនមានជាន់ដែលអ្នកស្វែងរកទេ"))
                : ListView.builder(
              padding:
              const EdgeInsets.symmetric(horizontal: 0),
              itemCount: _filteredFloors.length,
              itemBuilder: (context, index) =>
                  _buildFloorItem(_filteredFloors[index]),
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
          MaterialPageRoute(
            builder: (context) =>
                RoomPage(floorTitle: floor.title),
          ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.layers_outlined,
              color: Colors.black),
        ),
        title: Text(floor.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(floor.roomCount,
            style: const TextStyle(color: Colors.grey)),
        trailing: SizedBox(
          width: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _showOptionsMenu(floor),
                child: const Icon(Icons.more_vert,
                    color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}