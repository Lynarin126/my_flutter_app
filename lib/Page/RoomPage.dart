import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ============================
// Room Model (Firestore Compatible)
// ============================
class Room {
  final String id;
  final String roomNumber;
  String tenantName;
  String phone;
  String status;
  double rent;
  String moveInDate;
  String roomType;

  Room({
    required this.id,
    required this.roomNumber,
    required this.tenantName,
    required this.phone,
    required this.status,
    required this.rent,
    required this.moveInDate,
    this.roomType = "Normal",
  });

  factory Room.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return Room(
      id: doc.id,
      roomNumber: d['roomNumber'] ?? '',
      tenantName: d['tenantName'] ?? '',
      phone: d['phone'] ?? '',
      status: d['status'] ?? 'available',
      rent: (d['price'] ?? d['rent'] ?? 0).toDouble(),
      moveInDate: d['moveInDate'] ?? '',
      roomType: d['roomType'] ?? 'Normal',
    );
  }
}

class RoomPage extends StatefulWidget {
  final String floorTitle;
  const RoomPage({super.key, required this.floorTitle});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  String selectedFilter = "ទាំងអស់";
  String searchQuery = "";

  void _showAddRoomDialog() {
    final roomNumberController = TextEditingController();
    final rentController       = TextEditingController();
    String selectedStatus      = "available";
    String selectedType        = "Normal";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF27AE60).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.door_front_door_outlined, color: Color(0xFF27AE60)),
              ),
              const SizedBox(width: 12),
              const Text("បន្ថែមបន្ទប់ថ្មី", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              _buildDialogField(roomNumberController, "លេខបន្ទប់", Icons.tag),
              const SizedBox(height: 12),
              _buildDialogField(rentController, "តម្លៃជួល (\$)", Icons.attach_money, inputType: TextInputType.number),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: "ប្រភេទបន្ទប់"),
                items: const [DropdownMenuItem(value: "Normal", child: Text("ធម្មតា")), DropdownMenuItem(value: "VIP", child: Text("វីអាយភី"))],
                onChanged: (v) => setDialogState(() => selectedType = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(labelText: "ស្ថានភាព"),
                items: const [DropdownMenuItem(value: "available", child: Text("ទំនេរ")), DropdownMenuItem(value: "busy", child: Text("មានអ្នកជួល"))],
                onChanged: (v) => setDialogState(() => selectedStatus = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("បោះបង់", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27AE60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                if (roomNumberController.text.isEmpty) return;
                await FirebaseFirestore.instance.collection('rooms').add({
                  'roomNumber': roomNumberController.text,
                  'floor': widget.floorTitle,
                  'price': double.tryParse(rentController.text) ?? 0,
                  'status': selectedStatus,
                  'roomType': selectedType,
                });
                Navigator.pop(context);
              },
              child: const Text("រក្សាទុក", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTenantDialog(Room room) {
    final tenantNameController = TextEditingController();
    final phoneController      = TextEditingController();
    final rentController       = TextEditingController(text: room.rent.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF27AE60).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.person_add_outlined, color: Color(0xFF27AE60)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text("បន្ថែមអ្នកជួល - Room ${room.roomNumber}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            _buildDialogField(tenantNameController, "ឈ្មោះអ្នកជួល", Icons.person_outline),
            const SizedBox(height: 12),
            _buildDialogField(phoneController, "លេខទូរស័ព្ទ", Icons.phone_outlined, inputType: TextInputType.phone),
            const SizedBox(height: 12),
            _buildDialogField(rentController, "តម្លៃជួល (\$)", Icons.attach_money, inputType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("បោះបង់", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27AE60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              if (tenantNameController.text.isEmpty) return;
              await FirebaseFirestore.instance.collection('rooms').doc(room.id).update({
                'tenantName': tenantNameController.text,
                'phone': phoneController.text,
                'status': "busy",
                'rent': double.tryParse(rentController.text) ?? 0,
                'moveInDate': "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
              });
              Navigator.pop(context);
            },
            child: const Text("រក្សាទុក", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditRoomDialog(Room room) {
    final tenantNameController = TextEditingController(text: room.tenantName);
    final phoneController      = TextEditingController(text: room.phone);
    final rentController       = TextEditingController(text: room.rent.toString());
    String selectedStatus      = room.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.edit_outlined, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Text("កែប្រែ - Room ${room.roomNumber}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              _buildDialogField(tenantNameController, "ឈ្មោះអ្នកជួល", Icons.person_outline),
              const SizedBox(height: 12),
              _buildDialogField(phoneController, "លេខទូរស័ព្ទ", Icons.phone_outlined, inputType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildDialogField(rentController, "តម្លៃជួល (\$)", Icons.attach_money, inputType: TextInputType.number),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedStatus,
                    isExpanded: true,
                    items: const [DropdownMenuItem(value: "available", child: Text("ទំនេរ")), DropdownMenuItem(value: "busy", child: Text("មានអ្នកជួល"))],
                    onChanged: (value) => setDialogState(() => selectedStatus = value!),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("បោះបង់", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('rooms').doc(room.id).update({
                  'tenantName': tenantNameController.text,
                  'phone': phoneController.text,
                  'status': selectedStatus,
                  'rent': double.tryParse(rentController.text) ?? 0,
                });
                Navigator.pop(context);
              },
              child: const Text("រក្សាទុក", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label, IconData icon, {TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF27AE60), width: 1.5)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rooms').where('floor', isEqualTo: widget.floorTitle).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        final rooms = snapshot.data!.docs.map((doc) => Room.fromFirestore(doc)).toList();
        int totalRooms = rooms.length;
        int busyRooms = rooms.where((r) => r.status == "busy").length;
        int availableRooms = rooms.where((r) => r.status == "available").length;

        final filteredRooms = rooms.where((room) {
          bool matchesFilter = selectedFilter == "ទាំងអស់" ||
              (selectedFilter == "មានអ្នកជួល" && room.status == "busy") ||
              (selectedFilter == "ទំនេរ" && room.status == "available");
          bool matchesSearch = room.roomNumber.toLowerCase().contains(searchQuery.toLowerCase()) ||
              room.tenantName.toLowerCase().contains(searchQuery.toLowerCase());
          return matchesFilter && matchesSearch;
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 160,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF27AE60),
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.more_vert, color: Colors.white, size: 18),
                    ),
                    onPressed: () {},
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2ECC71), Color(0xFF27AE60), Color(0xFF1E8449)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("បន្ទប់ - ${widget.floorTitle}", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildStatChip("$totalRooms", "សរុប", Colors.white.withOpacity(0.3)),
                                const SizedBox(width: 8),
                                _buildStatChip("$busyRooms", "មានអ្នក", Colors.orange.withOpacity(0.5)),
                                const SizedBox(width: 8),
                                _buildStatChip("$availableRooms", "ទំនេរ", Colors.green.shade800.withOpacity(0.5)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 2))]),
                        child: TextField(
                          onChanged: (value) => setState(() => searchQuery = value),
                          decoration: InputDecoration(
                            hintText: "ស្វែងរកតាមលេខបន្ទប់ ឬឈ្មោះ...",
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(icon: Icon(Icons.clear, color: Colors.grey.shade400, size: 18), onPressed: () => setState(() => searchQuery = ""))
                                : null,
                            filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: ["ទាំងអស់", "មានអ្នកជួល", "ទំនេរ"].map((f) {
                          bool isActive = selectedFilter == f;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => selectedFilter = f),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isActive ? const Color(0xFF27AE60) : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [BoxShadow(color: isActive ? const Color(0xFF27AE60).withOpacity(0.3) : Colors.grey.shade200, blurRadius: 6, offset: const Offset(0, 2))],
                                ),
                                child: Text(f, style: TextStyle(color: isActive ? Colors.white : Colors.grey.shade600, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              filteredRooms.isEmpty
                  ? SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                        child: Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                      ),
                      const SizedBox(height: 16),
                      Text("មិនមានបន្ទប់", style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              )
                  : SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildRoomCard(filteredRooms[index]),
                    childCount: filteredRooms.length,
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddRoomDialog,
            backgroundColor: const Color(0xFF27AE60),
            elevation: 4,
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        );
      },
    );
  }

  Widget _buildStatChip(String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(count, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    bool isBusy = room.status == "busy";
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 85, height: 85,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isBusy ? [Colors.orange.shade100, Colors.orange.shade200] : [Colors.green.shade50, Colors.green.shade100],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(isBusy ? Icons.king_bed_outlined : Icons.bed_outlined, size: 38, color: isBusy ? Colors.orange.shade400 : Colors.green.shade400),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Room ${room.roomNumber}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1A1A2E))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: isBusy ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(width: 6, height: 6, decoration: BoxDecoration(color: isBusy ? Colors.orange : Colors.green, shape: BoxShape.circle)),
                                const SizedBox(width: 4),
                                Text(isBusy ? "មានអ្នក" : "ទំនេរ", style: TextStyle(color: isBusy ? Colors.orange.shade700 : Colors.green.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (isBusy) ...[
                        _buildInfoRow(Icons.person_outline, room.tenantName),
                        const SizedBox(height: 4),
                        _buildInfoRow(Icons.phone_outlined, room.phone.isEmpty ? "—" : room.phone),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildInfoRowExpanded(Icons.attach_money, "\$${room.rent.toStringAsFixed(0)}/ខែ", Colors.green.shade600),
                            const SizedBox(width: 12),
                            _buildInfoRowExpanded(Icons.calendar_today_outlined, room.moveInDate, Colors.blue.shade400),
                          ],
                        ),
                      ] else ...[
                        Text("បន្ទប់នេះទំនេរ", style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontStyle: FontStyle.italic)),
                        const SizedBox(height: 4),
                        Text("ទឹកប្រាក់ប្រចាំខែ: —", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: isBusy
                ? Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RoomDetailPage(room: room))),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    icon: Icon(Icons.visibility_outlined, size: 15, color: Colors.grey.shade600),
                    label: Text("View", style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showEditRoomDialog(room),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27AE60), padding: const EdgeInsets.symmetric(vertical: 8), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    icon: const Icon(Icons.edit_outlined, size: 15, color: Colors.white),
                    label: const Text("Edit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            )
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddTenantDialog(room),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27AE60), padding: const EdgeInsets.symmetric(vertical: 10), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                icon: const Icon(Icons.person_add_outlined, size: 16, color: Colors.white),
                label: const Text("+ បន្ថែមអ្នកជួល", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.grey.shade400),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }

  Widget _buildInfoRowExpanded(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
// ============================
// Room Detail Page
// ============================
class RoomDetailPage extends StatelessWidget {
  final Room room;
  const RoomDetailPage({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("បន្ទប់ ${room.roomNumber}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF27AE60),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailItem(Icons.person, "ឈ្មោះអ្នកជួល", room.tenantName.isEmpty ? "—" : room.tenantName),
                    const Divider(),
                    _buildDetailItem(Icons.phone, "លេខទូរស័ព្ទ", room.phone.isEmpty ? "—" : room.phone),
                    const Divider(),
                    _buildDetailItem(Icons.attach_money, "តម្លៃជួល", "\$${room.rent.toStringAsFixed(0)}/ខែ"),
                    const Divider(),
                    _buildDetailItem(Icons.calendar_today, "ថ្ងៃចូលស្នាក់", room.moveInDate.isEmpty ? "—" : room.moveInDate),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF27AE60)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

