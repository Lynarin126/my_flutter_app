import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Login.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  // Controllers
  final nameController        = TextEditingController();
  final emailController       = TextEditingController();
  final phoneController       = TextEditingController();
  final electricityController = TextEditingController();
  final waterController       = TextEditingController();
  final wifiController        = TextEditingController();

  // ✅ រូបភាព Profile
  File? _profileImage;
  String? _savedImagePath;
  bool isLoading = true;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    electricityController.dispose();
    waterController.dispose();
    wifiController.dispose();
    super.dispose();
  }

  // ============================
  // Load ទិន្នន័យ
  // ============================
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text        = prefs.getString('admin_name')        ?? "អ្នកគ្រប់គ្រង";
      emailController.text       = prefs.getString('admin_email')       ?? "movvoreach@gmail.com";
      phoneController.text       = prefs.getString('admin_phone')       ?? "016808238";
      electricityController.text = prefs.getString('price_electricity') ?? "700";
      waterController.text       = prefs.getString('price_water')       ?? "2000";
      wifiController.text        = prefs.getString('price_wifi')        ?? "10";
      _savedImagePath            = prefs.getString('profile_image');     // ✅ Load រូប

      // ✅ Load File រូបភាព
      if (_savedImagePath != null && _savedImagePath!.isNotEmpty) {
        final file = File(_savedImagePath!);
        if (file.existsSync()) {
          _profileImage = file;
        }
      }
      isLoading = false;
    });
  }

  // ============================
  // ✅ ជ្រើសរូបភាព
  // ============================
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "ជ្រើសរើសរូបភាព",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Camera
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt_outlined,
                    color: Color(0xFF27AE60)),
              ),
              title: const Text("ថតរូប"),
              subtitle: const Text("ប្រើ Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),

            // Gallery
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.photo_library_outlined,
                    color: Colors.blue),
              ),
              title: const Text("ជ្រើសពី Gallery"),
              subtitle: const Text("ជ្រើសរូបពី Phone"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),

            // Remove Photo (បើមានរូបរួចហើយ)
            if (_profileImage != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.red),
                ),
                title: const Text("លុបរូបភាព",
                    style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('profile_image');
                  setState(() {
                    _profileImage = null;
                    _savedImagePath = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  // ============================
  // ✅ Pick Image Function
  // ============================
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Compress 80%
        maxWidth: 500,
        maxHeight: 500,
      );

      if (pickedFile != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image', pickedFile.path);

        setState(() {
          _profileImage = File(pickedFile.path);
          _savedImagePath = pickedFile.path;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("បានផ្លាស់ប្តូររូបភាពដោយជោគជ័យ!"),
            backgroundColor: Color(0xFF27AE60),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // ============================
  // Save Profile
  // ============================
  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_name',  nameController.text);
    await prefs.setString('admin_email', emailController.text);
    await prefs.setString('admin_phone', phoneController.text);
    setState(() {});
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("បានរក្សាទុកព័ត៌មាន Admin ដោយជោគជ័យ!"),
        backgroundColor: Color(0xFF27AE60),
      ),
    );
  }

  // ============================
  // Save Invoice Settings
  // ============================
  Future<void> _saveInvoiceSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('price_electricity', electricityController.text);
    await prefs.setString('price_water',       waterController.text);
    await prefs.setString('price_wifi',        wifiController.text);
    setState(() {});
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("បានរក្សាទុកការកំណត់វិក្កយបត្រ!"),
        backgroundColor: Color(0xFF27AE60),
      ),
    );
  }

  // ============================
  // Dialog Edit Profile
  // ============================
  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("កែប្រែព័ត៌មាន Admin"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "ឈ្មោះ",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "លេខទូរស័ព្ទ",
                prefixIcon: const Icon(Icons.phone_outlined),
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
            onPressed: _saveProfile,
            child: const Text("រក្សាទុក",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ============================
  // Dialog Invoice Settings
  // ============================
  void _showInvoiceSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("កំណត់តម្លៃ"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: electricityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "តម្លៃអគ្គិសនី (រៀល/យូនីត)",
                prefixIcon: const Icon(Icons.electric_bolt,
                    color: Colors.orange),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: waterController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "តម្លៃទឹក (រៀល/គូប)",
                prefixIcon: const Icon(Icons.water_drop_outlined,
                    color: Colors.blue),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: wifiController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "តម្លៃ WiFi (\$/ខែ)",
                prefixIcon: const Icon(Icons.wifi,
                    color: Colors.green),
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
            onPressed: _saveInvoiceSettings,
            child: const Text("រក្សាទុក",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ============================
  // Dialog Confirm Logout
  // ============================
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ចាកចេញ"),
        content: const Text(
            "តើអ្នកប្រាកដជាចង់ចាកចេញពីគណនីមែនទេ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("បោះបង់"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_logged_in', false);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const LoginPage()),
                    (route) => false,
              );
            },
            child: const Text("ចាកចេញ",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
              color: Color(0xFF27AE60)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF27AE60),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "ការកំណត់",
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
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ============================
            // ✅ Profile Avatar + Edit Button
            // ============================
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      // Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF27AE60),
                              width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor:
                          const Color(0xFFE8F5E9),
                          // ✅ បង្ហាញរូបភាព ឬ Icon Default
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? const Icon(Icons.person,
                              size: 60,
                              color: Color(0xFF27AE60))
                              : null,
                        ),
                      ),

                      // ✅ Edit Icon នៅ corner ស្តាំក្រោម
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showImagePickerOptions,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF27AE60),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Text(
                    nameController.text,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text("Admin",
                      style: TextStyle(
                          color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("ព័ត៌មានផ្ទាល់ខ្លួន",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.email_outlined,
                            color: Color(0xFF27AE60), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(emailController.text,
                            style:
                            const TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.phone_outlined,
                            color: Color(0xFF27AE60), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(phoneController.text,
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Edit Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showEditProfileDialog,
                icon: const Icon(Icons.edit_outlined,
                    color: Color(0xFF27AE60)),
                label: const Text(
                  "កែប្រែប្រវត្តិរូប",
                  style: TextStyle(
                      color: Color(0xFF27AE60),
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(
                      color: Color(0xFF27AE60)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "វិក្កយបត្រ និង ការទូទាត់",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            const SizedBox(height: 10),

            // ExpansionTile 1
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              margin: const EdgeInsets.only(bottom: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ExpansionTile(
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                        Icons.monetization_on_outlined,
                        color: Color(0xFF27AE60)),
                  ),
                  title: const Text("វិក្កយបត្រប្រចាំខែ",
                      style: TextStyle(
                          fontWeight: FontWeight.w600)),
                  subtitle: const Text(
                      "មើល និងគ្រប់គ្រងវិក្កយបត្រប្រចាំខែ",
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey)),
                  children: [
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                          Icons.receipt_long_outlined,
                          color: Colors.grey),
                      title: const Text("វិក្កយបត្រខែនេះ"),
                      trailing: const Icon(
                          Icons.arrow_forward_ios, size: 14),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.history,
                          color: Colors.grey),
                      title: const Text("ប្រវត្តិវិក្កយបត្រ"),
                      trailing: const Icon(
                          Icons.arrow_forward_ios, size: 14),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),

            // ExpansionTile 2
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              margin: const EdgeInsets.only(bottom: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ExpansionTile(
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.receipt_outlined,
                        color: Color(0xFF27AE60)),
                  ),
                  title: const Text("ការកំណត់វិក្កយបត្រ",
                      style: TextStyle(
                          fontWeight: FontWeight.w600)),
                  subtitle: const Text(
                      "កំណត់ការកំណត់វិក្កយបត្រផ្ទាល់ខ្លួន",
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey)),
                  children: [
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.electric_bolt,
                          color: Colors.orange),
                      title: const Text("តម្លៃអគ្គិសនី"),
                      subtitle: Text(
                          "${electricityController.text} រៀល/យូនីត"),
                      trailing: const Icon(
                          Icons.arrow_forward_ios, size: 14),
                      onTap: _showInvoiceSettingsDialog,
                    ),
                    ListTile(
                      leading: const Icon(
                          Icons.water_drop_outlined,
                          color: Colors.blue),
                      title: const Text("តម្លៃទឹក"),
                      subtitle: Text(
                          "${waterController.text} រៀល/គូប"),
                      trailing: const Icon(
                          Icons.arrow_forward_ios, size: 14),
                      onTap: _showInvoiceSettingsDialog,
                    ),
                    ListTile(
                      leading: const Icon(Icons.wifi,
                          color: Colors.green),
                      title: const Text("តម្លៃ WiFi"),
                      subtitle: Text(
                          "${wifiController.text} \$/ខែ"),
                      trailing: const Icon(
                          Icons.arrow_forward_ios, size: 14),
                      onTap: _showInvoiceSettingsDialog,
                    ),
                  ],
                ),
              ),
            ),

            // Logout Button
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showLogoutDialog,
                icon: const Icon(Icons.logout,
                    color: Colors.white),
                label: const Text(
                  "ចាកចេញ",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                      vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}