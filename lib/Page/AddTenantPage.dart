import 'package:flutter/material.dart';

class AddTenantPage extends StatefulWidget {
  const AddTenantPage({super.key});

  @override
  State<AddTenantPage> createState() => _AddTenantPageState();
}

class _AddTenantPageState extends State<AddTenantPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final rentController = TextEditingController();
  final addressController = TextEditingController();
  final depositController = TextEditingController();

  String? selectedGender;
  String? selectedFloor;
  String? selectedRoom;
  DateTime? selectedDate;

  bool hasElectricity = true;
  bool hasWater = true;
  bool hasWifi = true;
  bool hasOther = true;

  final List<String> genders = ["ប្រុស", "ស្រី"];
  final List<String> floors = [
    "ជាន់ ទី៦", "ជាន់ ទី៧", "ជាន់ ទី៨",
    "ជាន់ ទី៩", "ជាន់ ទី១០", "ជាន់ ទី១១"
  ];
  final List<String> rooms = ["001", "002", "003", "004", "005"];

  // ============================
  // DatePicker
  // ============================
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF27AE60),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  // ============================
  // Input Decoration
  // ============================
  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: Color(0xFF27AE60), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    rentController.dispose();
    addressController.dispose();
    depositController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF27AE60),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "បង្កើតអតិថិជន",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ============================
              // ឈ្មោះពេញ
              // ============================
              _buildLabel("ឈ្មោះពេញ"),
              TextFormField(
                controller: nameController,
                decoration: _inputDecoration(
                  "បញ្ចូលឈ្មោះពេញរបស់អ្នកជួល",
                  icon: Icons.person_outline,
                ),
                validator: (val) =>
                val!.isEmpty ? "សូមបញ្ចូលឈ្មោះ" : null,
              ),
              const SizedBox(height: 14),

              // ============================
              // លេខទូរស័ព្ទ
              // ============================
              _buildLabel("លេខទូរស័ព្ទ"),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration(
                  "បញ្ចូលលេខទូរស័ព្ទ",
                  icon: Icons.phone_outlined,
                ),
                validator: (val) =>
                val!.isEmpty ? "សូមបញ្ចូលលេខទូរស័ព្ទ" : null,
              ),
              const SizedBox(height: 14),

              // ============================
              // កាលបរិច្ឆេទចូលស្នាក់នៅ
              // ============================
              _buildLabel("កាលបរិច្ឆេទចូលស្នាក់នៅ"),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate == null
                            ? "ជ្រើសរើសកាលបរិច្ឆេទ"
                            : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                        style: TextStyle(
                          color: selectedDate == null
                              ? Colors.grey
                              : Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      const Icon(Icons.calendar_today_outlined,
                          color: Colors.grey, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ============================
              // ភេទ
              // ============================
              _buildLabel("ភេទ"),
              _buildDropdown(
                hint: "ជ្រើសរើសភេទ",
                value: selectedGender,
                items: genders,
                icon: Icons.people_outline,
                onChanged: (val) =>
                    setState(() => selectedGender = val),
              ),
              const SizedBox(height: 14),

              // ============================
              // អាសយដ្ឋាន
              // ============================
              _buildLabel("អាសយដ្ឋាន"),
              TextFormField(
                controller: addressController,
                decoration: _inputDecoration(
                  "បញ្ចូលអាសយដ្ឋាន",
                  icon: Icons.location_on_outlined,
                ),
              ),
              const SizedBox(height: 14),

              // ============================
              // ជាន់
              // ============================
              _buildLabel("ជាន់"),
              _buildDropdown(
                hint: "ជ្រើសរើសជាន់",
                value: selectedFloor,
                items: floors,
                icon: Icons.layers_outlined,
                onChanged: (val) =>
                    setState(() => selectedFloor = val),
              ),
              const SizedBox(height: 14),

              // ============================
              // លេខបន្ទប់
              // ============================
              _buildLabel("លេខបន្ទប់"),
              _buildDropdown(
                hint: "ជ្រើសរើសលេខបន្ទប់",
                value: selectedRoom,
                items: rooms,
                icon: Icons.door_front_door_outlined,
                onChanged: (val) =>
                    setState(() => selectedRoom = val),
              ),
              const SizedBox(height: 14),

              // ============================
              // តម្លៃជួលប្រចាំខែ
              // ============================
              _buildLabel("តម្លៃជួលប្រចាំខែ"),
              TextFormField(
                controller: rentController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  "ឧ: 150\$",
                  icon: Icons.attach_money,
                ),
                validator: (val) =>
                val!.isEmpty ? "សូមបញ្ចូលតម្លៃជួល" : null,
              ),
              const SizedBox(height: 14),

              // ============================
              // កម្រៃប្រើប្រាស់សេវាកម្ម
              // ============================
              _buildLabel("កម្រៃប្រើប្រាស់សេវាកម្ម"),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCheckbox(
                      "អគ្គិស",
                      hasElectricity,
                          (val) =>
                          setState(() => hasElectricity = val!),
                    ),
                    _buildCheckbox(
                      "ទឹក",
                      hasWater,
                          (val) => setState(() => hasWater = val!),
                    ),
                    _buildCheckbox(
                      "WiFi",
                      hasWifi,
                          (val) => setState(() => hasWifi = val!),
                    ),
                    _buildCheckbox(
                      "សេវាផ្សេងៗ",
                      hasOther,
                          (val) => setState(() => hasOther = val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ============================
              // តម្លៃដាក់ប្រាក់បញ្ញើ
              // ============================
              _buildLabel("តម្លៃដាក់ប្រាក់បញ្ញើ"),
              TextFormField(
                controller: depositController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  "ឧ: 60\$",
                  icon: Icons.savings_outlined,
                ),
              ),
              const SizedBox(height: 24),

              // ============================
              // Save Button
              // ============================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    padding:
                    const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("បានរក្សាទុកដោយជោគជ័យ!"),
                          backgroundColor: Color(0xFF27AE60),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    "រក្សាទុក",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================
  // Label Widget
  // ============================
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  // ============================
  // Dropdown Widget
  // ============================
  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Row(
            children: [
              Icon(icon, color: Colors.grey, size: 18),
              const SizedBox(width: 8),
              Text(hint,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 13)),
            ],
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items
              .map((item) => DropdownMenuItem(
            value: item,
            child: Text(item),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ============================
  // Checkbox Widget
  // ============================
  Widget _buildCheckbox(
      String label, bool value, ValueChanged<bool?> onChanged) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF27AE60),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4)),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}