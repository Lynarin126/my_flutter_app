import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'Login.dart';
import 'MonthlyInvoicePage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final electricityController = TextEditingController();
  final waterController = TextEditingController();
  final wifiController = TextEditingController();

  File? _selectedImage;
  bool _isUploadingImage = false;
  final ImagePicker _picker = ImagePicker();

  // Firebase Instances
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  // ជ្រើសរើសរូបភាព & បង្ហោះទៅ Firebase Storage
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF27AE60)),
              ),
              title: const Text("ថតរូប"),
              subtitle: const Text("ប្រើ Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.photo_library_outlined, color: Colors.blue),
              ),
              title: const Text("ជ្រើសពី Gallery"),
              subtitle: const Text("ជ្រើសរូបពី Phone"),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (pickedFile != null && currentUser != null) {
        setState(() => _isUploadingImage = true);

        // Upload ទៅ Firebase Storage
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/${currentUser!.uid}.jpg');

        UploadTask uploadTask = storageRef.putFile(File(pickedFile.path));
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Save Download URL ចូលក្នុង Firestore User Document
        await _firestore.collection('users').doc(currentUser!.uid).update({
          'photoUrl': downloadUrl,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("បានផ្លាស់ប្តូររូបភាពដោយជោគជ័យ!"),
              backgroundColor: Color(0xFF27AE60),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error uploading image: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  // ============================
  // រក្សាទុក Admin Profile ទៅ Firebase Firestore
  // ============================
  Future<void> _saveProfile() async {
    if (currentUser == null) return;

    try {
      await _firestore.collection('users').doc(currentUser!.uid).set({
        'fullName': nameController.text,
        'email': emailController.text,
        'phoneNumber': phoneController.text,
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("បានរក្សាទុកព័ត៌មាន Admin ដោយជោគជ័យ!"),
            backgroundColor: Color(0xFF27AE60),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(" Error saving profile: $e")),
      );
    }
  }

  // ============================
  // រក្សាទុកតម្លៃវិក្កយបត្រ ទៅ Firebase Firestore
  // ============================
  Future<void> _saveInvoiceSettings() async {
    try {
      await _firestore.collection('settings').doc('invoice_prices').set({
        'price_electricity': electricityController.text,
        'price_water': waterController.text,
        'price_wifi': wifiController.text,
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("បានរក្សាទុកការកំណត់វិក្កយបត្រ!"),
            backgroundColor: Color(0xFF27AE60),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(" Error saving settings: $e")),
      );
    }
  }

  // Dialog Edit Profile
  void _showEditProfileDialog(Map<String, dynamic> userData) {
    nameController.text = userData['fullName'] ?? '';
    emailController.text = userData['email'] ?? currentUser?.email ?? '';
    phoneController.text = userData['phoneNumber'] ?? '';

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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "លេខទូរស័ព្ទ",
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("បោះបង់", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27AE60)),
            onPressed: _saveProfile,
            child: const Text("រក្សាទុក", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Dialog Invoice Settings
  void _showInvoiceSettingsDialog(Map<String, dynamic> prices) {
    electricityController.text = prices['price_electricity'] ?? '700';
    waterController.text = prices['price_water'] ?? '2000';
    wifiController.text = prices['price_wifi'] ?? '10';

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
                prefixIcon: const Icon(Icons.electric_bolt, color: Colors.orange),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: waterController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "តម្លៃទឹក (រៀល/គូប)",
                prefixIcon: const Icon(Icons.water_drop_outlined, color: Colors.blue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: wifiController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "តម្លៃ WiFi (\$/ខែ)",
                prefixIcon: const Icon(Icons.wifi, color: Colors.green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("បោះបង់", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27AE60)),
            onPressed: _saveInvoiceSettings,
            child: const Text("រក្សាទុក", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Dialog Confirm Logout ជាមួយ Firebase Auth
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ចាកចេញ"),
        content: const Text("តើអ្នកប្រាកដជាចង់ចាកចេញពីគណនីមែនទេ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("បោះបង់"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                );
              }
            },
            child: const Text("ចាកចេញ", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("សូមចូលប្រើប្រាស់គណនីជាមុនសិន")),
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
          style: TextStyle(color: Colors.black, fontFamily: 'Fasthand'),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(currentUser!.uid).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF27AE60)),
            );
          }

          Map<String, dynamic> userData =
              userSnapshot.data?.data() as Map<String, dynamic>? ?? {};

          String name = userData['fullName'] ?? 'អ្នកគ្រប់គ្រង';
          String email = userData['email'] ?? currentUser?.email ?? 'គ្មានអ៊ីមែល';
          String phone = userData['phoneNumber'] ?? 'គ្មានលេខទូរស័ព្ទ';
          String? photoUrl = userData['photoUrl'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // ============================
                // Profile Avatar + Edit Button
                // ============================
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF27AE60), width: 3),
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
                              backgroundColor: const Color(0xFFE8F5E9),
                              backgroundImage:
                              photoUrl != null ? NetworkImage(photoUrl) : null,
                              child: _isUploadingImage
                                  ? const CircularProgressIndicator(color: Color(0xFF27AE60))
                                  : photoUrl == null
                                  ? const Icon(Icons.person, size: 60, color: Color(0xFF27AE60))
                                  : null,
                            ),
                          ),
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
                                  border: Border.all(color: Colors.white, width: 2),
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
                        name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text("Admin", style: TextStyle(color: Colors.grey, fontSize: 13)),
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
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
                            child: Text(email, style: const TextStyle(fontSize: 14)),
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
                          Text(phone, style: const TextStyle(fontSize: 14)),
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
                    onPressed: () => _showEditProfileDialog(userData),
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFF27AE60)),
                    label: const Text(
                      "កែប្រែប្រវត្តិរូប",
                      style: TextStyle(
                          color: Color(0xFF27AE60),
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF27AE60)),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 10),

                // ============================
                // Settings Section (Invoice Prices)
                // ============================
                StreamBuilder<DocumentSnapshot>(
                  stream: _firestore.collection('settings').doc('invoice_prices').snapshots(),
                  builder: (context, priceSnapshot) {
                    Map<String, dynamic> priceData =
                        priceSnapshot.data?.data() as Map<String, dynamic>? ?? {};

                    String elec = priceData['price_electricity'] ?? '700';
                    String water = priceData['price_water'] ?? '2000';
                    String wifi = priceData['price_wifi'] ?? '10';

                    return Column(
                      children: [
                        // ExpansionTile 1: Invoice Navigation
                        // ប្តូរទៅជា ListTile ជំនួសឱ្យ ExpansionTile វិញដើម្បីភាពងាយស្រួល
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.receipt_long_outlined, color: Color(0xFF27AE60)),
                            ),
                            title: const Text(
                              "វិក្កយបត្រប្រចាំខែ",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: const Text(
                              "មើល និងគ្រប់គ្រងវិក្កយបត្រប្រចាំខែទាំងអស់",
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MonthlyInvoicePage(),
                              ),
                            ),
                          ),
                        ),


                        // ExpansionTile 2: Invoice Prices
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
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: const Text("កំណត់ការកំណត់វិក្កយបត្រផ្ទាល់ខ្លួន",
                                  style: TextStyle(fontSize: 12, color: Colors.grey)),
                              children: [
                                const Divider(height: 1),
                                ListTile(
                                  leading:
                                  const Icon(Icons.electric_bolt, color: Colors.orange),
                                  title: const Text("តម្លៃអគ្គិសនី"),
                                  subtitle: Text("$elec រៀល/យូនីត"),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                                  onTap: () => _showInvoiceSettingsDialog(priceData),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.water_drop_outlined,
                                      color: Colors.blue),
                                  title: const Text("តម្លៃទឹក"),
                                  subtitle: Text("$water រៀល/គូប"),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                                  onTap: () => _showInvoiceSettingsDialog(priceData),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.wifi, color: Colors.green),
                                  title: const Text("តម្លៃ WiFi"),
                                  subtitle: Text("$wifi \$/ខែ"),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                                  onTap: () => _showInvoiceSettingsDialog(priceData),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // Logout Button
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showLogoutDialog,
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      "ចាកចេញ",
                      style: TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}