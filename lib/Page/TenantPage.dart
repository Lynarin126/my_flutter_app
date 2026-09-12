import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AddTenantPage.dart';

class Tenant {
  final String id;
  String name, roomNumber, floor, status, phone, paymentStatus;
  double rent;
  final Color avatarColor;

  Tenant({
    required this.id, required this.name, required this.roomNumber, required this.floor,
    required this.status, required this.phone, required this.paymentStatus, required this.rent, required this.avatarColor,
  });

  factory Tenant.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>?;
    return Tenant(
      id: doc.id,
      name: d?['name'] ?? '',
      roomNumber: d?['roomNumber'] ?? '',
      floor: d?['floor'] ?? '',
      status: d?['status'] ?? 'ជួល',
      phone: d?['phone'] ?? '',
      paymentStatus: d?['paymentStatus'] ?? 'unpaid',
      rent: (d?['rent'] as num?)?.toDouble() ?? 0.0,
      avatarColor: Color(d?['avatarColor'] ?? 0xFFE74C3C),
    );
  }
}

class TenantPage extends StatefulWidget {
  const TenantPage({super.key});
  @override
  State<TenantPage> createState() => _TenantPageState();
}

class _TenantPageState extends State<TenantPage> {
  String searchQuery = "";
  String selectedFloor = "ជាន់ទាំងអស់";
  String selectedFilter = "ទាំងអស់";
  List<Tenant> tenants = [];

  late StreamSubscription<QuerySnapshot> _sub;
  late StreamSubscription<QuerySnapshot> _floorsSub;

  // 🔹 Floor list is no longer hardcoded — it is populated live from the
  // Firestore `floors` collection (field `title`). "ជាន់ទាំងអស់" (All floors)
  // is always kept as the first option for the filter.
  List<String> floorList = ["ជាន់ទាំងអស់"];

  @override
  void initState() {
    super.initState();

    _sub = FirebaseFirestore.instance.collection('tenants').snapshots().listen((snap) {
      if (mounted) {
        setState(() {
          tenants = snap.docs.map((doc) => Tenant.fromFirestore(doc)).toList();
        });
      }
    });

    // 🔹 Listen to the `floors` collection in real time so the filter and any
    // dialog dropdown always reflect the latest floors without needing a
    // manual refresh.
    _floorsSub = FirebaseFirestore.instance
        .collection('floors')
        .orderBy('title')
        .snapshots()
        .listen((snap) {
      if (!mounted) return;
      final titles = snap.docs
          .map((doc) => (doc.data()['title'] ?? '').toString())
          .where((t) => t.isNotEmpty)
          .toList();
      setState(() {
        floorList = ["ជាន់ទាំងអស់", ...titles];
        // បើជាន់ដែលកំពុងជ្រើសរើសមិននៅក្នុងបញ្ជីថ្មីទៀតទេ (ឧ. ត្រូវបានលុប) ត្រឡប់ទៅ default វិញ
        if (!floorList.contains(selectedFloor)) {
          selectedFloor = "ជាន់ទាំងអស់";
        }
      });
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    _floorsSub.cancel();
    super.dispose();
  }

  List<Tenant> get _filteredTenants {
    return tenants.where((t) {
      final mSearch = t.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          t.roomNumber.contains(searchQuery) || t.phone.contains(searchQuery);
      final mFloor = selectedFloor == "ជាន់ទាំងអស់" || t.floor == selectedFloor;
      final mPay = selectedFilter == "ទាំងអស់" ||
          (selectedFilter == "បានបង់" && t.paymentStatus == "paid") ||
          (selectedFilter == "មិនទាន់បង់" && t.paymentStatus == "unpaid");
      return mSearch && mFloor && mPay;
    }).toList();
  }

  int get _paidCount => tenants.where((t) => t.paymentStatus == "paid").length;
  int get _unpaidCount => tenants.where((t) => t.paymentStatus == "unpaid").length;

  // បន្ថែមមុខងារបង្ហាញព័ត៌មានលម្អិត (Detail View)
  void _showTenantDetailDialog(Tenant tenant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("ព័ត៌មានលម្អិតអ្នកជួល", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(leading: const Icon(Icons.person, color: Colors.blue), title: const Text("ឈ្មោះ"), subtitle: Text(tenant.name)),
            ListTile(leading: const Icon(Icons.door_front_door, color: Colors.green), title: const Text("លេខបន្ទប់"), subtitle: Text("${tenant.roomNumber} (${tenant.floor})")),
            ListTile(leading: const Icon(Icons.phone, color: Colors.orange), title: const Text("លេខទូរស័ព្ទ"), subtitle: Text(tenant.phone.isEmpty ? "—" : tenant.phone)),
            ListTile(leading: const Icon(Icons.attach_money, color: Colors.red), title: const Text("តម្លៃជួល"), subtitle: Text("\$${tenant.rent.toStringAsFixed(2)}/ខែ")),
            ListTile(
              leading: Icon(tenant.paymentStatus == "paid" ? Icons.check_circle : Icons.cancel, color: tenant.paymentStatus == "paid" ? Colors.green : Colors.red),
              title: const Text("ស្ថានភាពបង់ប្រាក់"),
              subtitle: Text(tenant.paymentStatus == "paid" ? "បានបង់" : "មិនទាន់បង់"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("បិទ")),
        ],
      ),
    );
  }

  // 🔹 ឥឡូវនេះបើក Dialog កែប្រែជា Widget ដាច់ដោយឡែក (_EditTenantDialog)
  // ព្រោះវាត្រូវការគ្រប់គ្រង State ផ្ទាល់ខ្លួន (floor/room fetching, loading state)
  void _showEditTenantDialog(Tenant tenant) {
    // លុប "ជាន់ទាំងអស់" ចេញ ព្រោះក្នុង Dialog កែប្រែ មិនត្រូវឲ្យជ្រើសរើស Option នេះទេ
    final realFloors = floorList.where((f) => f != "ជាន់ទាំងអស់").toList();
    showDialog(
      context: context,
      builder: (context) => _EditTenantDialog(tenant: tenant, floorList: realFloors),
    );
  }

  void _showDeleteDialog(Tenant tenant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("លុបអ្នកជួល"),
        content: Text("តើអ្នកប្រាកដជាចង់លុប \"${tenant.name}\" មែនទេ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("បោះបង់")),
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('tenants').doc(tenant.id).delete();
              Navigator.pop(context);
            },
            child: const Text("លុប"),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(Tenant tenant) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: const Icon(Icons.info_outline, color: Colors.green), title: const Text("ព័ត៌មានលម្អិត"), onTap: () { Navigator.pop(context); _showTenantDetailDialog(tenant); }),
          ListTile(leading: const Icon(Icons.edit, color: Colors.blue), title: const Text("កែប្រែ"), onTap: () { Navigator.pop(context); _showEditTenantDialog(tenant); }),
          ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text("លុប"), onTap: () { Navigator.pop(context); _showDeleteDialog(tenant); }),
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
          SliverAppBar(
            expandedHeight: 150, pinned: true, automaticallyImplyLeading: false, backgroundColor: const Color(0xFF27AE60),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF2ECC71), Color(0xFF27AE60)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text("អ្នកជួល", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(children: [
                          _buildStatChip("${tenants.length}", "សរុប", Colors.white.withOpacity(0.3)),
                          const SizedBox(width: 8),
                          _buildStatChip("$_paidCount", "បានបង់", Colors.green.shade800.withOpacity(0.5)),
                          const SizedBox(width: 8),
                          _buildStatChip("$_unpaidCount", "មិនទាន់បង់", Colors.red.withOpacity(0.4)),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) => setState(() => searchQuery = val),
                    decoration: const InputDecoration(hintText: "ស្វែងរកឈ្មោះ, លេខបន្ទប់, ទូរស័ព្ទ...", prefixIcon: Icon(Icons.search)),
                  ),
                  const SizedBox(height: 12),
                  // 🔹 Floor filter dropdown - now built from the live `floorList`
                  DropdownButton<String>(
                    value: selectedFloor, isExpanded: true,
                    items: floorList.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                    onChanged: (val) => setState(() => selectedFloor = val!),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: ["ទាំងអស់", "បានបង់", "មិនទាន់បង់"].map((f) => GestureDetector(
                      onTap: () => setState(() => selectedFilter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: selectedFilter == f ? const Color(0xFF27AE60) : Colors.white,
                        child: Text(f, style: TextStyle(color: selectedFilter == f ? Colors.white : Colors.black)),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
          _filteredTenants.isEmpty
              ? const SliverFillRemaining(child: Center(child: Text("មិនមានអ្នកជួល")))
              : SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => TenantCard(
                  tenant: _filteredTenants[index],
                  onOptionsTap: () => _showOptionsMenu(_filteredTenants[index]),
                  onEditTap: () => _showEditTenantDialog(_filteredTenants[index]),
                  onViewTap: () => _showTenantDetailDialog(_filteredTenants[index]),
                      onPaymentToggle: () async {
                        final t = _filteredTenants[index];
                        final nextStatus = t.paymentStatus == "paid" ? "unpaid" : "paid";

                        // បង្កើត WriteBatch សម្រាប់រក្សាទុកទិន្នន័យទាំងសងខាងក្នុងពេលតែមួយ
                        final batch = FirebaseFirestore.instance.batch();

                        // ១. កែប្រែស្ថានភាពបង់ប្រាក់ក្នុង tenants
                        batch.update(
                          FirebaseFirestore.instance.collection('tenants').doc(t.id),
                          {'paymentStatus': nextStatus},
                        );

                        // ២. ស្វែងរក និងកែប្រែស្ថានភាពបង់ប្រាក់ក្នុង payments (សម្រាប់ខែបច្ចុប្បន្ន)
                        final currentMonth = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}";
                        final paymentSnap = await FirebaseFirestore.instance
                            .collection('payments')
                            .where('roomId', isEqualTo: t.roomNumber)
                            .where('billingMonth', isEqualTo: currentMonth)
                            .get();

                        for (var doc in paymentSnap.docs) {
                          batch.update(doc.reference, {'status': nextStatus});
                        }

                        try {
                          await batch.commit(); // រក្សាទុកទៅ Firebase ជាមួយគ្នា
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("មានបញ្ហាក្នុងការរក្សាទុក៖ $e")),
                            );
                          }
                        }
                      },

                    ),
                childCount: _filteredTenants.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTenantPage())),
        backgroundColor: const Color(0xFF27AE60),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildStatChip(String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text("$count $label", style: const TextStyle(color: Colors.white, fontSize: 11)),
    );
  }
}
class _EditTenantDialog extends StatefulWidget {
  final Tenant tenant;
  final List<String> floorList;
  const _EditTenantDialog({required this.tenant, required this.floorList});

  @override
  State<_EditTenantDialog> createState() => _EditTenantDialogState();
}

class _EditTenantDialogState extends State<_EditTenantDialog> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController rentController;

  late String selectedFloor;
  String? selectedRoom;
  String paymentStatus = 'unpaid';

  List<String> roomNumbers = [];
  bool isLoadingRooms = true;

  @override
  void initState() {
    super.initState();
    final tenant = widget.tenant;

    nameController = TextEditingController(text: tenant.name);
    phoneController = TextEditingController(text: tenant.phone);
    rentController = TextEditingController(text: tenant.rent.toString());
    paymentStatus = tenant.paymentStatus;

    // បើជាន់របស់ Tenant នេះមិននៅក្នុងបញ្ជីជាន់បច្ចុប្បន្នទៀតទេ (ឧ. ត្រូវបានលុប)
    // ត្រូវប្រើជាន់ទីមួយក្នុងបញ្ជីជំនួសវិញ ដើម្បីជៀសវាង Dropdown crash
    selectedFloor = widget.floorList.contains(tenant.floor)
        ? tenant.floor
        : (widget.floorList.isNotEmpty ? widget.floorList.first : '');

    // 🔹 ចាប់ផ្តើមដោយដាក់ Room បច្ចុប្បន្នរបស់ Tenant ចូល List រួចហើយភ្លាមៗ
    // ដើម្បីកុំឲ្យ Dropdown crash មុនពេល Firestore ទាញយកទិន្នន័យចប់សព្វគ្រប់
    roomNumbers = [tenant.roomNumber];
    selectedRoom = tenant.roomNumber;

    _loadRoomsForFloor(selectedFloor, keepCurrentRoom: true);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    rentController.dispose();
    super.dispose();
  }

  // 🔹 ទាញយកលេខបន្ទប់ទាំងអស់ពី Collection `rooms` ដែលមាន floor ត្រូវនឹងជាន់ដែលបានជ្រើសរើស
  Future<void> _loadRoomsForFloor(String floor, {bool keepCurrentRoom = false}) async {
    if (floor.isEmpty) {
      setState(() {
        roomNumbers = keepCurrentRoom ? [widget.tenant.roomNumber] : [];
        selectedRoom = keepCurrentRoom ? widget.tenant.roomNumber : null;
        isLoadingRooms = false;
      });
      return;
    }

    setState(() => isLoadingRooms = true);

    try {
      final snap = await FirebaseFirestore.instance
          .collection('rooms')
          .where('floor', isEqualTo: floor) // 🔧 ADJUST FIELD NAME if needed
          .get();

      final fetched = snap.docs
          .map((doc) => (doc.data()['roomNumber'] ?? '').toString()) // 🔧 ADJUST FIELD NAME if needed
          .where((r) => r.isNotEmpty)
          .toSet();

      // 🔹 Prevent Dropdown Crash: បើកំពុងស្ថិតលើជាន់ដើមរបស់ Tenant (មិនបានប្តូរជាន់)
      // ត្រូវប្រាកដថាបន្ទប់បច្ចុប្បន្នរបស់គាត់នៅតែមានក្នុងបញ្ជី សូម្បីតែ Query មិនបានត្រឡប់វា
      // មកវិញក៏ដោយ (ឧ. status របស់បន្ទប់នោះជា "occupied" ហើយមិនស្ថិតក្នុង available list)
      if (keepCurrentRoom || floor == widget.tenant.floor) {
        fetched.add(widget.tenant.roomNumber);
      }

      final sortedRooms = fetched.toList()..sort();

      setState(() {
        roomNumbers = sortedRooms;
        // បើ Room ដែលកំពុងជ្រើសរើសមិននៅក្នុងបញ្ជីថ្មីទៀតទេ (ព្រោះប្តូរជាន់) ត្រូវ Reset ទៅ null
        // ជំនួសឲ្យទុក Value ដែលមិនត្រូវគ្នា (Dropdown នឹង crash បើមិន Reset)
        if (selectedRoom == null || !roomNumbers.contains(selectedRoom)) {
          selectedRoom = keepCurrentRoom ? widget.tenant.roomNumber : null;
        }
        isLoadingRooms = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingRooms = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("មិនអាចទាញយកបញ្ជីបន្ទប់បានទេ៖ ${e.toString()}")),
      );
    }
  }

  void _onFloorChanged(String? newFloor) {
    if (newFloor == null || newFloor == selectedFloor) return;
    setState(() {
      selectedFloor = newFloor;
      selectedRoom = null;
      roomNumbers = [];
      isLoadingRooms = true;
    });
    _loadRoomsForFloor(newFloor);
  }

  void _save() {
    if (selectedRoom == null || selectedRoom!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("សូមជ្រើសរើសលេខបន្ទប់!")),
      );
      return;
    }

    FirebaseFirestore.instance.collection('tenants').doc(widget.tenant.id).update({
      'name': nameController.text,
      'roomNumber': selectedRoom,
      'phone': phoneController.text,
      'floor': selectedFloor,
      'paymentStatus': paymentStatus,
      'rent': double.tryParse(rentController.text) ?? 0,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(children: [
        Icon(Icons.edit_outlined, color: Colors.blue),
        SizedBox(width: 12),
        Text("កែប្រែអ្នកជួល", style: TextStyle(fontWeight: FontWeight.bold)),
      ]),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(nameController, "ឈ្មោះអ្នកជួល", Icons.person_outline),
            _buildDialogField(phoneController, "លេខទូរស័ព្ទ", Icons.phone_outlined, inputType: TextInputType.phone),
            _buildDialogField(rentController, "តម្លៃជួល (\$)", Icons.attach_money, inputType: TextInputType.number),

            // 🔹 Floor Dropdown — ទាញយកចេញពី Firestore `floors` collection
            _buildLabel("ជាន់", Icons.layers_outlined),
            DropdownButtonFormField<String>(
              value: widget.floorList.contains(selectedFloor) ? selectedFloor : null,
              isExpanded: true,
              items: widget.floorList
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: _onFloorChanged,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            // 🔹 Room Dropdown — ទាញយកចេញពី Firestore `rooms` collection
            // ត្រូវបានត្រង (filter) តាមជាន់ដែលបានជ្រើសរើសខាងលើ
            _buildLabel("លេខបន្ទប់", Icons.door_front_door_outlined),
            isLoadingRooms
                ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
                : DropdownButtonFormField<String>(
              value: (selectedRoom != null && roomNumbers.contains(selectedRoom))
                  ? selectedRoom
                  : null,
              isExpanded: true,
              hint: const Text("ជ្រើសរើសលេខបន្ទប់"),
              items: roomNumbers
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (val) => setState(() => selectedRoom = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            if (!isLoadingRooms && roomNumbers.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  "គ្មានបន្ទប់នៅជាន់នេះទេ",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 12),

            _buildLabel("ស្ថានភាពបង់ប្រាក់", Icons.payment_outlined),
            DropdownButtonFormField<String>(
              value: paymentStatus,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: "paid", child: Text("បានបង់")),
                DropdownMenuItem(value: "unpaid", child: Text("មិនទាន់បង់")),
              ],
              onChanged: (val) => setState(() => paymentStatus = val!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("បោះបង់")),
        ElevatedButton(onPressed: _save, child: const Text("រក្សាទុក")),
      ],
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label, IconData icon, {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 18), border: const OutlineInputBorder()),
      ),
    );
  }
}

class TenantCard extends StatelessWidget {
  final Tenant tenant;
  final VoidCallback onOptionsTap, onEditTap, onPaymentToggle, onViewTap;
  const TenantCard({super.key, required this.tenant, required this.onOptionsTap, required this.onEditTap, required this.onPaymentToggle, required this.onViewTap});

  @override
  Widget build(BuildContext context) {
    bool isPaid = tenant.paymentStatus == "paid";
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(backgroundColor: tenant.avatarColor, radius: 28, child: Text(tenant.name.isNotEmpty ? tenant.name[0].toUpperCase() : "?", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(tenant.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), _buildPaymentBadge(isPaid)]),
                      const SizedBox(height: 6),
                      Text("Room ${tenant.roomNumber} • ${tenant.floor}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      Text(tenant.phone.isEmpty ? "—" : tenant.phone, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      Text("\$${tenant.rent.toStringAsFixed(0)}/ខែ", style: TextStyle(color: Colors.green.shade600, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                IconButton(icon: Icon(Icons.more_vert, color: Colors.grey.shade400), onPressed: onOptionsTap),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: onViewTap, child: const Text("View"))),
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton(onPressed: onEditTap, child: const Text("Edit"))),
                const SizedBox(width: 8),
                GestureDetector(onTap: onPaymentToggle, child: Icon(isPaid ? Icons.check_circle_outline : Icons.cancel_outlined, color: isPaid ? Colors.green : Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBadge(bool isPaid) {
    return Container(padding: const EdgeInsets.all(4), child: Text(isPaid ? "បានបង់" : "មិនទាន់បង់", style: TextStyle(color: isPaid ? Colors.green : Colors.red, fontSize: 10)));
  }
}