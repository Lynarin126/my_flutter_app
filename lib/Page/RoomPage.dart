import 'package:flutter/material.dart';

class RoomPage extends StatefulWidget {
  final String floorTitle;
  const RoomPage({super.key, required this.floorTitle});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  String selectedFilter = "ទាំងអស់";
  String searchQuery = "";

  List<Room> rooms = [
    Room(roomNumber: "004", tenantName: "Narin",
        phone: "012345678", status: "busy",
        rent: 150, moveInDate: "01/01/2024"),
    Room(roomNumber: "005", tenantName: "Reach",
        phone: "0887654321", status: "busy",
        rent: 120, moveInDate: "15/02/2024"),
    Room(roomNumber: "006", tenantName: "",
        phone: "", status: "available",
        rent: 0, moveInDate: ""),
    Room(roomNumber: "007", tenantName: "",
        phone: "", status: "available",
        rent: 0, moveInDate: ""),
  ];

  List<Room> get _filteredRooms {
    return rooms.where((room) {
      bool matchesFilter = selectedFilter == "ទាំងអស់" ||
          (selectedFilter == "មានអ្នកជួល" && room.status == "busy") ||
          (selectedFilter == "ទំនេរ" && room.status == "available");
      bool matchesSearch =
          room.roomNumber.toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
              room.tenantName.toLowerCase()
                  .contains(searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  // ============================
  // Dialog Add បន្ទប់
  // ============================
  void _showAddRoomDialog() {
    final roomNumberController = TextEditingController();
    final tenantNameController = TextEditingController();
    final phoneController      = TextEditingController();
    final rentController       = TextEditingController();
    String selectedStatus      = "available";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          titlePadding:
          const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding:
          const EdgeInsets.fromLTRB(24, 16, 24, 0),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                    Icons.door_front_door_outlined,
                    color: Color(0xFF27AE60)),
              ),
              const SizedBox(width: 12),
              const Text("បន្ថែមបន្ទប់ថ្មី",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              _buildDialogField(roomNumberController,
                  "លេខបន្ទប់", Icons.tag),
              const SizedBox(height: 12),
              _buildDialogField(tenantNameController,
                  "ឈ្មោះអ្នកជួល", Icons.person_outline),
              const SizedBox(height: 12),
              _buildDialogField(phoneController,
                  "លេខទូរស័ព្ទ", Icons.phone_outlined,
                  inputType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildDialogField(rentController,
                  "តម្លៃជួល (\$)", Icons.attach_money,
                  inputType: TextInputType.number),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border:
                  Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedStatus,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                          value: "available",
                          child: Text("ទំនេរ")),
                      DropdownMenuItem(
                          value: "busy",
                          child: Text("មានអ្នកជួល")),
                    ],
                    onChanged: (value) => setDialogState(
                            () => selectedStatus = value!),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("បោះបង់",
                  style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 10),
              ),
              onPressed: () {
                if (roomNumberController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                        Text("សូមបំពេញលេខបន្ទប់!")),
                  );
                  return;
                }
                setState(() {
                  rooms.add(Room(
                    roomNumber: roomNumberController.text,
                    tenantName: tenantNameController.text,
                    phone: phoneController.text,
                    status: selectedStatus,
                    rent: double.tryParse(
                        rentController.text) ??
                        0,
                    moveInDate: selectedStatus == "busy"
                        ? "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"
                        : "",
                  ));
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                    Text("បានបន្ថែមបន្ទប់ដោយជោគជ័យ!"),
                    backgroundColor: Color(0xFF27AE60),
                  ),
                );
              },
              child: const Text("រក្សាទុក",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ============================
  // Dialog Add អ្នកជួល
  // ============================
  void _showAddTenantDialog(Room room) {
    final tenantNameController = TextEditingController();
    final phoneController      = TextEditingController();
    final rentController       = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        titlePadding:
        const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding:
        const EdgeInsets.fromLTRB(24, 16, 24, 0),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_add_outlined,
                  color: Color(0xFF27AE60)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "បន្ថែមអ្នកជួល - Room ${room.roomNumber}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            _buildDialogField(tenantNameController,
                "ឈ្មោះអ្នកជួល", Icons.person_outline),
            const SizedBox(height: 12),
            _buildDialogField(phoneController,
                "លេខទូរស័ព្ទ", Icons.phone_outlined,
                inputType: TextInputType.phone),
            const SizedBox(height: 12),
            _buildDialogField(rentController,
                "តម្លៃជួល (\$)", Icons.attach_money,
                inputType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("បោះបង់",
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27AE60),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 10),
            ),
            onPressed: () {
              if (tenantNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          "សូមបញ្ចូលឈ្មោះអ្នកជួល!")),
                );
                return;
              }
              setState(() {
                room.tenantName = tenantNameController.text;
                room.phone      = phoneController.text;
                room.status     = "busy";
                room.rent =
                    double.tryParse(rentController.text) ?? 0;
                room.moveInDate =
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                  Text("បានបន្ថែមអ្នកជួលដោយជោគជ័យ!"),
                  backgroundColor: Color(0xFF27AE60),
                ),
              );
            },
            child: const Text("រក្សាទុក",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ============================
  // Dialog Edit
  // ============================
  void _showEditRoomDialog(Room room) {
    final tenantNameController =
    TextEditingController(text: room.tenantName);
    final phoneController =
    TextEditingController(text: room.phone);
    final rentController =
    TextEditingController(text: room.rent.toString());
    String selectedStatus = room.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          titlePadding:
          const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding:
          const EdgeInsets.fromLTRB(24, 16, 24, 0),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_outlined,
                    color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Text("កែប្រែ - Room ${room.roomNumber}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              _buildDialogField(tenantNameController,
                  "ឈ្មោះអ្នកជួល", Icons.person_outline),
              const SizedBox(height: 12),
              _buildDialogField(phoneController,
                  "លេខទូរស័ព្ទ", Icons.phone_outlined,
                  inputType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildDialogField(rentController,
                  "តម្លៃជួល (\$)", Icons.attach_money,
                  inputType: TextInputType.number),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border:
                  Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedStatus,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                          value: "available",
                          child: Text("ទំនេរ")),
                      DropdownMenuItem(
                          value: "busy",
                          child: Text("មានអ្នកជួល")),
                    ],
                    onChanged: (value) => setDialogState(
                            () => selectedStatus = value!),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("បោះបង់",
                  style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 10),
              ),
              onPressed: () {
                setState(() {
                  room.tenantName = tenantNameController.text;
                  room.phone      = phoneController.text;
                  room.status     = selectedStatus;
                  room.rent =
                      double.tryParse(rentController.text) ??
                          0;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("បានកែប្រែដោយជោគជ័យ!"),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              child: const Text("រក្សាទុក",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ============================
  // Helper: Dialog TextField
  // ============================
  Widget _buildDialogField(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType inputType = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        prefixIcon:
        Icon(icon, size: 18, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color(0xFF27AE60), width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalRooms =
        rooms.length;
    int busyRooms =
        rooms.where((r) => r.status == "busy").length;
    int availableRooms =
        rooms.where((r) => r.status == "available").length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [

          // ============================
          // SliverAppBar
          // ============================
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF27AE60),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_back,
                    color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.more_vert,
                      color: Colors.white, size: 18),
                ),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF2ECC71),
                      Color(0xFF27AE60),
                      Color(0xFF1E8449),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        20, 50, 20, 16),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      mainAxisAlignment:
                      MainAxisAlignment.end,
                      children: [
                        Text(
                          "បន្ទប់ - ${widget.floorTitle}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildStatChip(
                                "$totalRooms",
                                "សរុប",
                                Colors.white
                                    .withOpacity(0.3)),
                            const SizedBox(width: 8),
                            _buildStatChip(
                                "$busyRooms",
                                "មានអ្នក",
                                Colors.orange
                                    .withOpacity(0.5)),
                            const SizedBox(width: 8),
                            _buildStatChip(
                                "$availableRooms",
                                "ទំនេរ",
                                Colors.green.shade800
                                    .withOpacity(0.5)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ============================
          // Search + Filter
          // ============================
          SliverToBoxAdapter(
            child: Padding(
              padding:
              const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  // Search
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) => setState(
                              () => searchQuery = value),
                      decoration: InputDecoration(
                        hintText:
                        "ស្វែងរកតាមលេខបន្ទប់ ឬឈ្មោះ...",
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13),
                        prefixIcon: Icon(Icons.search,
                            color: Colors.grey.shade400),
                        suffixIcon:
                        searchQuery.isNotEmpty
                            ? IconButton(
                          icon: Icon(
                              Icons.clear,
                              color: Colors
                                  .grey.shade400,
                              size: 18),
                          onPressed: () =>
                              setState(() =>
                              searchQuery =
                              ""),
                        )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                        const EdgeInsets.symmetric(
                            vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Filter
                  Row(
                    children: [
                      "ទាំងអស់",
                      "មានអ្នកជួល",
                      "ទំនេរ"
                    ].map((f) {
                      bool isActive = selectedFilter == f;
                      return Padding(
                        padding:
                        const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(
                                  () => selectedFilter = f),
                          child: AnimatedContainer(
                            duration: const Duration(
                                milliseconds: 200),
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF27AE60)
                                  : Colors.white,
                              borderRadius:
                              BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: isActive
                                      ? const Color(
                                      0xFF27AE60)
                                      .withOpacity(0.3)
                                      : Colors
                                      .grey.shade200,
                                  blurRadius: 6,
                                  offset:
                                  const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              f,
                              style: TextStyle(
                                color: isActive
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // ============================
          // Room List
          // ============================
          _filteredRooms.isEmpty
              ? SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.search_off,
                        size: 48,
                        color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 16),
                  Text("មិនមានបន្ទប់",
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text("សូមស្វែងរកម្តងទៀត",
                      style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13)),
                ],
              ),
            ),
          )
              : SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildRoomCard(
                    _filteredRooms[index]),
                childCount: _filteredRooms.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRoomDialog,
        backgroundColor: const Color(0xFF27AE60),
        elevation: 4,
        child: const Icon(Icons.add,
            color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildStatChip(
      String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(count,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    bool isBusy = room.status == "busy";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isBusy
                            ? [
                          Colors.orange.shade100,
                          Colors.orange.shade200,
                        ]
                            : [
                          Colors.green.shade50,
                          Colors.green.shade100,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(
                      isBusy
                          ? Icons.king_bed_outlined
                          : Icons.bed_outlined,
                      size: 38,
                      color: isBusy
                          ? Colors.orange.shade400
                          : Colors.green.shade400,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Room ${room.roomNumber}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4),
                            decoration: BoxDecoration(
                              color: isBusy
                                  ? const Color(0xFFFFF3E0)
                                  : const Color(0xFFE8F5E9),
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isBusy
                                        ? Colors.orange
                                        : Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isBusy
                                      ? "មានអ្នក"
                                      : "ទំនេរ",
                                  style: TextStyle(
                                    color: isBusy
                                        ? Colors
                                        .orange.shade700
                                        : Colors
                                        .green.shade700,
                                    fontSize: 11,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      if (isBusy) ...[
                        _buildInfoRow(Icons.person_outline,
                            room.tenantName),
                        const SizedBox(height: 4),
                        _buildInfoRow(Icons.phone_outlined,
                            room.phone.isEmpty
                                ? "—"
                                : room.phone),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildInfoRowExpanded(
                                Icons.attach_money,
                                "\$${room.rent.toStringAsFixed(0)}/ខែ",
                                Colors.green.shade600),
                            const SizedBox(width: 12),
                            _buildInfoRowExpanded(
                                Icons.calendar_today_outlined,
                                room.moveInDate,
                                Colors.blue.shade400),
                          ],
                        ),
                      ] else ...[
                        Text(
                          "បន្ទប់នេះទំនេរ",
                          style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                              fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "ទឹកប្រាក់ប្រចាំខែ: —",
                          style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Buttons
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            child: isBusy
                ? Row(
              children: [
                // ✅ View Button Navigate
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RoomDetailPage(room: room),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(
                          vertical: 8),
                      side: BorderSide(
                          color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(
                        Icons.visibility_outlined,
                        size: 15,
                        color: Colors.grey.shade600),
                    label: Text(
                      "View",
                      style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Edit Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _showEditRoomDialog(room),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF27AE60),
                      padding:
                      const EdgeInsets.symmetric(
                          vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(
                        Icons.edit_outlined,
                        size: 15,
                        color: Colors.white),
                    label: const Text(
                      "Edit",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ),
                ),
              ],
            )
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    _showAddTenantDialog(room),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF27AE60),
                  padding: const EdgeInsets.symmetric(
                      vertical: 10),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(
                    Icons.person_add_outlined,
                    size: 16,
                    color: Colors.white),
                label: const Text(
                  "+ បន្ថែមអ្នកជួល",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
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
        Text(text,
            style: TextStyle(
                color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }

  Widget _buildInfoRowExpanded(
      IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ============================
// Room Model
// ============================
class Room {
  final String roomNumber;
  String tenantName;
  String phone;
  String status;
  double rent;
  String moveInDate;

  Room({
    required this.roomNumber,
    required this.tenantName,
    required this.phone,
    required this.status,
    required this.rent,
    required this.moveInDate,
  });
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF27AE60),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_back,
                    color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF2ECC71),
                      Color(0xFF27AE60),
                      Color(0xFF1E8449),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color:
                          Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.king_bed_outlined,
                          size: 42,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Room ${room.roomNumber}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                          Colors.white.withOpacity(0.2),
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: room.status == "busy"
                                    ? Colors.orange
                                    : Colors.greenAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              room.status == "busy"
                                  ? "មានអ្នកជួល"
                                  : "ទំនេរ",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Tenant Info
                  _buildSectionTitle("ព័ត៌មានអ្នកជួល",
                      Icons.person_outline),
                  const SizedBox(height: 10),
                  _buildInfoCard([
                    _buildInfoItem(
                        Icons.person,
                        "ឈ្មោះ",
                        room.tenantName.isEmpty
                            ? "—"
                            : room.tenantName,
                        Colors.blue),
                    _buildDivider(),
                    _buildInfoItem(
                        Icons.phone,
                        "លេខទូរស័ព្ទ",
                        room.phone.isEmpty ? "—" : room.phone,
                        Colors.green),
                    _buildDivider(),
                    _buildInfoItem(
                        Icons.calendar_today,
                        "ថ្ងៃចូលស្នាក់",
                        room.moveInDate.isEmpty
                            ? "—"
                            : room.moveInDate,
                        Colors.orange),
                  ]),

                  const SizedBox(height: 20),

                  // Payment Info
                  _buildSectionTitle(
                      "ព័ត៌មានទូទាត់", Icons.attach_money),
                  const SizedBox(height: 10),
                  _buildInfoCard([
                    _buildInfoItem(
                        Icons.monetization_on,
                        "តម្លៃជួល",
                        room.rent == 0
                            ? "—"
                            : "\$${room.rent.toStringAsFixed(0)}/ខែ",
                        Colors.green),
                    _buildDivider(),
                    _buildInfoItem(
                        Icons.receipt_long,
                        "ស្ថានភាព",
                        room.status == "busy"
                            ? "កំពុងជួល"
                            : "ទំនេរ",
                        room.status == "busy"
                            ? Colors.orange
                            : Colors.green),
                  ]),

                  const SizedBox(height: 20),

                  // Room Info
                  _buildSectionTitle("ព័ត៌មានបន្ទប់",
                      Icons.door_front_door_outlined),
                  const SizedBox(height: 10),
                  _buildInfoCard([
                    _buildInfoItem(Icons.tag, "លេខបន្ទប់",
                        room.roomNumber, Colors.purple),
                    _buildDivider(),
                    _buildInfoItem(
                        Icons.layers_outlined,
                        "ស្ថានភាព",
                        room.status == "busy"
                            ? "មានអ្នកជួល"
                            : "ទំនេរ",
                        room.status == "busy"
                            ? Colors.orange
                            : Colors.green),
                  ]),

                  const SizedBox(height: 30),

                  // Back Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF27AE60),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white),
                      label: const Text(
                        "ត្រឡប់ក្រោយ",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF27AE60)),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E))),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoItem(IconData icon, String label,
      String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF1A1A2E))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: Colors.grey.shade100);
  }
}
