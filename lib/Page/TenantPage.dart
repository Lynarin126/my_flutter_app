import 'package:flutter/material.dart';
import 'AddTenantPage.dart';

// ============================
// Tenant Model
// ============================
class Tenant {
  String name;
  String roomNumber;
  String floor;
  String status;
  String phone;
  String paymentStatus; // ✅ "paid" ឬ "unpaid"
  double rent;
  final Color avatarColor;

  Tenant({
    required this.name,
    required this.roomNumber,
    required this.floor,
    required this.status,
    required this.phone,
    required this.paymentStatus,
    required this.rent,
    required this.avatarColor,
  });
}

// ============================
// TenantPage
// ============================
class TenantPage extends StatefulWidget {
  const TenantPage({super.key});
  @override
  State<TenantPage> createState() => _TenantPageState();
}

class _TenantPageState extends State<TenantPage> {
  String searchQuery    = "";
  String selectedFloor  = "ជាន់ទាំងអស់";
  String selectedFilter = "ទាំងអស់"; // ✅ All/Paid/Unpaid

  final List<Tenant> tenants = [
    Tenant(
      name: "Narin",
      roomNumber: "004",
      floor: "ជាន់ ទី៦",
      status: "ជួល",
      phone: "012345678",
      paymentStatus: "unpaid",
      rent: 150,
      avatarColor: const Color(0xFFE74C3C),
    ),
    Tenant(
      name: "Reach",
      roomNumber: "001",
      floor: "ជាន់ ទី៦",
      status: "ជួល",
      phone: "0887654321",
      paymentStatus: "paid",
      rent: 120,
      avatarColor: const Color(0xFF2ECC71),
    ),
    Tenant(
      name: "Reach1",
      roomNumber: "001",
      floor: "ជាន់ ទី៧",
      status: "ជួល",
      phone: "0123456789",
      paymentStatus: "unpaid",
      rent: 100,
      avatarColor: const Color(0xFF3498DB),
    ),
    Tenant(
      name: "Reach2",
      roomNumber: "002",
      floor: "ជាន់ ទី៨",
      status: "ជួល",
      phone: "0987654321",
      paymentStatus: "paid",
      rent: 130,
      avatarColor: const Color(0xFFE67E22),
    ),
    Tenant(
      name: "Reach3",
      roomNumber: "003",
      floor: "ជាន់ ទី៩",
      status: "ជួល",
      phone: "0112233445",
      paymentStatus: "unpaid",
      rent: 110,
      avatarColor: const Color(0xFF9B59B6),
    ),
    Tenant(
      name: "Dara",
      roomNumber: "005",
      floor: "ជាន់ ទី១១",
      status: "ជួល",
      phone: "0556677889",
      paymentStatus: "paid",
      rent: 140,
      avatarColor: const Color(0xFF1ABC9C),
    ),
  ];

  // ============================
  // Floor List
  // ============================
  List<String> get floorList {
    final floors = tenants.map((t) => t.floor).toSet().toList();
    floors.insert(0, "ជាន់ទាំងអស់");
    return floors;
  }

  // ============================
  // Filter Logic
  // ============================
  List<Tenant> get _filteredTenants {
    return tenants.where((t) {
      final matchSearch =
          t.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              t.roomNumber.contains(searchQuery) ||
              t.phone.contains(searchQuery);

      final matchFloor = selectedFloor == "ជាន់ទាំងអស់" ||
          t.floor == selectedFloor;

      final matchPayment = selectedFilter == "ទាំងអស់" ||
          (selectedFilter == "បានបង់" && t.paymentStatus == "paid") ||
          (selectedFilter == "មិនទាន់បង់" && t.paymentStatus == "unpaid");

      return matchSearch && matchFloor && matchPayment;
    }).toList();
  }

  // ============================
  // Stats
  // ============================
  int get _paidCount =>
      tenants.where((t) => t.paymentStatus == "paid").length;
  int get _unpaidCount =>
      tenants.where((t) => t.paymentStatus == "unpaid").length;

  // ============================
  // Dialog Edit
  // ============================
  void _showEditTenantDialog(Tenant tenant) {
    final nameController =
    TextEditingController(text: tenant.name);
    final roomController =
    TextEditingController(text: tenant.roomNumber);
    final phoneController =
    TextEditingController(text: tenant.phone);
    final rentController =
    TextEditingController(text: tenant.rent.toString());
    String dialogFloor   = tenant.floor;
    String paymentStatus = tenant.paymentStatus;

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
              const Text("កែប្រែអ្នកជួល",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                _buildDialogField(nameController,
                    "ឈ្មោះអ្នកជួល", Icons.person_outline),
                const SizedBox(height: 12),
                _buildDialogField(roomController,
                    "លេខបន្ទប់",
                    Icons.door_front_door_outlined,
                    inputType: TextInputType.number),
                const SizedBox(height: 12),
                _buildDialogField(phoneController,
                    "លេខទូរស័ព្ទ", Icons.phone_outlined,
                    inputType: TextInputType.phone),
                const SizedBox(height: 12),
                _buildDialogField(rentController,
                    "តម្លៃជួល (\$)", Icons.attach_money,
                    inputType: TextInputType.number),
                const SizedBox(height: 12),
                // Floor Dropdown
                _buildDropdownField(
                  value: dialogFloor,
                  label: "ជាន់",
                  icon: Icons.layers_outlined,
                  items: [
                    "ជាន់ ទី៦","ជាន់ ទី៧","ជាន់ ទី៨",
                    "ជាន់ ទី៩","ជាន់ ទី១០","ជាន់ ទី១១"
                  ],
                  onChanged: (val) =>
                      setDialogState(() => dialogFloor = val!),
                ),
                const SizedBox(height: 12),
                // Payment Dropdown
                _buildDropdownField(
                  value: paymentStatus,
                  label: "ស្ថានភាពបង់ប្រាក់",
                  icon: Icons.payment_outlined,
                  items: ["paid", "unpaid"],
                  itemLabels: ["បានបង់", "មិនទាន់បង់"],
                  onChanged: (val) =>
                      setDialogState(() => paymentStatus = val!),
                ),
              ],
            ),
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
                  tenant.name          = nameController.text;
                  tenant.roomNumber    = roomController.text;
                  tenant.phone         = phoneController.text;
                  tenant.floor         = dialogFloor;
                  tenant.paymentStatus = paymentStatus;
                  tenant.rent =
                      double.tryParse(rentController.text) ?? 0;
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
  // Dialog Delete
  // ============================
  void _showDeleteDialog(Tenant tenant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline,
                  color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text("លុបអ្នកជួល",
                style:
                TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
            "តើអ្នកប្រាកដជាចង់លុប \"${tenant.name}\" មែនទេ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("បោះបង់",
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              setState(() => tenants.remove(tenant));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                  Text("បានលុប \"${tenant.name}\"!"),
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

  // ============================
  // Bottom Sheet Options
  // ============================
  void _showOptionsMenu(Tenant tenant) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: tenant.avatarColor,
                    radius: 24,
                    child: Text(
                      tenant.name[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(tenant.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Text(
                          "${tenant.roomNumber}, ${tenant.floor}",
                          style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13)),
                    ],
                  ),
                  const Spacer(),
                  // Payment Badge
                  _buildPaymentBadge(
                      tenant.paymentStatus, small: false),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit,
                    color: Colors.blue, size: 20),
              ),
              title: const Text("កែប្រែ",
                  style:
                  TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _showEditTenantDialog(tenant);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete,
                    color: Colors.red, size: 20),
              ),
              title: const Text("លុប",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(tenant);
              },
            ),
            const SizedBox(height: 10),
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

  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    List<String>? itemLabels,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Row(children: [
            Icon(icon, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 13)),
          ]),
          items: items.asMap().entries.map((e) {
            return DropdownMenuItem(
              value: e.value,
              child: Text(itemLabels != null
                  ? itemLabels[e.key]
                  : e.value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ============================
  // Payment Badge Widget
  // ============================
  Widget _buildPaymentBadge(String status,
      {bool small = true}) {
    bool isPaid = status == "paid";
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 8 : 12,
          vertical: small ? 3 : 6),
      decoration: BoxDecoration(
        color: isPaid
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPaid
              ? const Color(0xFF27AE60)
              : Colors.red.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: small ? 6 : 8,
            height: small ? 6 : 8,
            decoration: BoxDecoration(
              color: isPaid
                  ? const Color(0xFF27AE60)
                  : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: small ? 4 : 6),
          Text(
            isPaid ? "បានបង់" : "មិនទាន់បង់",
            style: TextStyle(
              color: isPaid
                  ? const Color(0xFF27AE60)
                  : Colors.red,
              fontSize: small ? 10 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [

          // ============================
          // ✅ SliverAppBar
          // ============================
          SliverAppBar(
            expandedHeight: 150,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF27AE60),
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
                        20, 10, 20, 16),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      mainAxisAlignment:
                      MainAxisAlignment.end,
                      children: [
                        const Text(
                          "អ្នកជួល",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Stats Row
                        Row(
                          children: [
                            _buildStatChip(
                                "${tenants.length}",
                                "សរុប",
                                Colors.white
                                    .withOpacity(0.3)),
                            const SizedBox(width: 8),
                            _buildStatChip(
                                "$_paidCount",
                                "បានបង់",
                                Colors.green.shade800
                                    .withOpacity(0.5)),
                            const SizedBox(width: 8),
                            _buildStatChip(
                                "$_unpaidCount",
                                "មិនទាន់បង់",
                                Colors.red
                                    .withOpacity(0.4)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
          ),

          // ============================
          // ✅ Search + Filter
          // ============================
          SliverToBoxAdapter(
            child: Padding(
              padding:
              const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  // Search Bar
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
                      onChanged: (val) =>
                          setState(() => searchQuery = val),
                      decoration: InputDecoration(
                        hintText:
                        "ស្វែងរកឈ្មោះ, លេខបន្ទប់, ទូរស័ព្ទ...",
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13),
                        prefixIcon: Icon(Icons.search,
                            color: Colors.grey.shade400),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.clear,
                              color:
                              Colors.grey.shade400,
                              size: 18),
                          onPressed: () => setState(
                                  () => searchQuery = ""),
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

                  // ✅ Floor Dropdown + Filter Chips Row
                  Row(
                    children: [
                      // Floor Dropdown
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.grey.shade200),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedFloor,
                              isExpanded: true,
                              icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 18),
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87),
                              items: floorList
                                  .map((f) => DropdownMenuItem(
                                value: f,
                                child: Row(
                                  children: [
                                    Icon(
                                        Icons
                                            .layers_outlined,
                                        size: 14,
                                        color: Colors
                                            .grey),
                                    const SizedBox(
                                        width: 6),
                                    Text(f,
                                        style:
                                        const TextStyle(
                                            fontSize:
                                            12)),
                                  ],
                                ),
                              ))
                                  .toList(),
                              onChanged: (val) => setState(
                                      () => selectedFloor = val!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ✅ Payment Filter Chips
                  Row(
                    children: [
                      "ទាំងអស់",
                      "បានបង់",
                      "មិនទាន់បង់"
                    ].map((f) {
                      bool isActive = selectedFilter == f;
                      Color activeColor =
                      f == "មិនទាន់បង់"
                          ? Colors.red
                          : const Color(0xFF27AE60);
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
                                horizontal: 16,
                                vertical: 8),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? activeColor
                                  : Colors.white,
                              borderRadius:
                              BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: isActive
                                      ? activeColor
                                      .withOpacity(0.3)
                                      : Colors.grey.shade200,
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
                                fontSize: 12,
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
          // ✅ Tenant List
          // ============================
          _filteredTenants.isEmpty
              ? SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                    const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person_off,
                        size: 48,
                        color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 16),
                  Text("មិនមានអ្នកជួល",
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
                    (context, index) => TenantCard(
                  tenant: _filteredTenants[index],
                  onOptionsTap: () => _showOptionsMenu(
                      _filteredTenants[index]),
                  onEditTap: () =>
                      _showEditTenantDialog(
                          _filteredTenants[index]),
                  onPaymentToggle: () {
                    setState(() {
                      final t = _filteredTenants[index];
                      t.paymentStatus =
                      t.paymentStatus == "paid"
                          ? "unpaid"
                          : "paid";
                    });
                  },
                ),
                childCount: _filteredTenants.length,
              ),
            ),
          ),
        ],
      ),

      // ============================
      // ✅ FAB
      // ============================
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const AddTenantPage()),
        ),
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
                  fontSize: 13)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}

// ============================
// ✅ Tenant Card Widget
// ============================
class TenantCard extends StatelessWidget {
  final Tenant tenant;
  final VoidCallback onOptionsTap;
  final VoidCallback onEditTap;
  final VoidCallback onPaymentToggle;

  const TenantCard({
    super.key,
    required this.tenant,
    required this.onOptionsTap,
    required this.onEditTap,
    required this.onPaymentToggle,
  });

  @override
  Widget build(BuildContext context) {
    bool isPaid = tenant.paymentStatus == "paid";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          // ============================
          // Top Section
          // ============================
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: tenant.avatarColor,
                      radius: 28,
                      child: Text(
                        tenant.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    // Online Dot
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isPaid
                              ? const Color(0xFF27AE60)
                              : Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 14),

                // Info
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
                            tenant.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          // Payment Badge
                          _buildPaymentBadge(isPaid),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Room + Floor
                      Row(
                        children: [
                          Icon(Icons.door_front_door_outlined,
                              size: 13,
                              color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            "Room ${tenant.roomNumber}  •  ${tenant.floor}",
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Phone
                      Row(
                        children: [
                          Icon(Icons.phone_outlined,
                              size: 13,
                              color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            tenant.phone.isEmpty
                                ? "—"
                                : tenant.phone,
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Rent
                      Row(
                        children: [
                          Icon(Icons.attach_money,
                              size: 13,
                              color: Colors.green.shade400),
                          const SizedBox(width: 4),
                          Text(
                            "\$${tenant.rent.toStringAsFixed(0)}/ខែ",
                            style: TextStyle(
                              color: Colors.green.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // More Options
                IconButton(
                  icon: Icon(Icons.more_vert,
                      color: Colors.grey.shade400),
                  onPressed: onOptionsTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // ============================
          // Divider
          // ============================
          Divider(
              height: 1,
              color: Colors.grey.shade100,
              indent: 14,
              endIndent: 14),

          // ============================
          // Bottom Buttons
          // ============================
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Row(
              children: [
                // View Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8),
                      side: BorderSide(
                          color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(Icons.visibility_outlined,
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
                const SizedBox(width: 8),

                // Edit Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onEditTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF27AE60),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined,
                        size: 15, color: Colors.white),
                    label: const Text(
                      "Edit",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // ✅ Payment Toggle Button
                GestureDetector(
                  onTap: onPaymentToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFEBEE),
                      borderRadius:
                      BorderRadius.circular(10),
                      border: Border.all(
                        color: isPaid
                            ? const Color(0xFF27AE60)
                            : Colors.red.shade300,
                      ),
                    ),
                    child: Icon(
                      isPaid
                          ? Icons.check_circle_outline
                          : Icons.cancel_outlined,
                      size: 20,
                      color: isPaid
                          ? const Color(0xFF27AE60)
                          : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBadge(bool isPaid) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPaid
              ? const Color(0xFF27AE60)
              : Colors.red.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isPaid
                  ? const Color(0xFF27AE60)
                  : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isPaid ? "បានបង់" : "មិនទាន់បង់",
            style: TextStyle(
              color: isPaid
                  ? const Color(0xFF27AE60)
                  : Colors.red,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}