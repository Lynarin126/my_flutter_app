import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // 🔹 ប៊ូតុងចុះឈ្មោះតាមអ៊ីមែលធម្មតា
  Future<void> _registerUser() async {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage("សូមបំពេញព័ត៌មានឲ្យបានគ្រប់គ្រាន់!");
      return;
    }
    if (password != confirmPassword) {
      _showMessage("ពាក្យសម្ងាត់ទាំងពីរមិនត្រូវគ្នាមិនត្រូវគ្នាទេ!");
      return;
    }
    if (password.length < 6) {
      _showMessage("ពាក្យសម្ងាត់ត្រូវមានយ៉ាងតិច ៦ ខ្ទង់!");
      return;
    }

    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid, 'fullName': name, 'phoneNumber': phone, 'email': email, 'createdAt': FieldValue.serverTimestamp(),
      });

      _showMessage("ចុះឈ្មោះជោគជ័យ!", isError: false);
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = "មានបញ្ហាក្នុងការចុះឈ្មោះ";
      if (e.code == 'email-already-in-use') message = "អ៊ីមែលនេះមានគណនីរួចហើយ!";
      else if (e.code == 'invalid-email') message = "ទម្រង់អ៊ីមែលមិនត្រឹមត្រូវ!";
      else if (e.code == 'weak-password') message = "ពាក្យសម្ងាត់ខ្សោយពេក!";
      _showMessage(message);
    } catch (e) {
      _showMessage("កើតមានកំហុស៖ ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🔹 បើក Link ខាងក្រៅតាម Browser
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      final bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        _showMessage("មិនអាចបើក Link បានទេ!");
      }
    } catch (e) {
      _showMessage("កើតមានកំហុសពេលបើក Link៖ ${e.toString()}");
    }
  }

  // 🔹 Functions សម្រាប់ភ្ជាប់គណនីសង្គម (Social Sign-in) — បើក Link ខាងក្រៅ
  Future<void> _signInWithGoogle() async {
    await _launchURL('https://www.google.com');
    // TODO: អនុវត្ត Google Sign-In ជាមួយ package google_sign_in តាមក្រោយ
  }

  Future<void> _signInWithFacebook() async {
    await _launchURL('https://www.facebook.com');
    // TODO: អនុវត្ត Facebook Login ជាមួយ package flutter_facebook_auth តាមក្រោយ
  }

  Future<void> _signInWithTikTok() async {
    await _launchURL('https://www.tiktok.com');
    // TODO: អនុវត្ត TikTok Sign-In តាមក្រោយ
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green));
  }

  @override
  void dispose() {
    _nameController.dispose(); _phoneController.dispose(); _emailController.dispose();
    _passwordController.dispose(); _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF64B5F6)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text("បង្កើតគណនីថ្មី", textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontFamily: 'Fasthand', color: Colors.white)),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)]),
                        child: Column(
                          children: [
                            _buildField("ឈ្មោះពេញ", Icons.person, _nameController),
                            const SizedBox(height: 15),
                            _buildField("លេខទូរស័ព្ទ", Icons.phone, _phoneController, keyboardType: TextInputType.phone),
                            const SizedBox(height: 15),
                            _buildField("អ៊ីមែល", Icons.email, _emailController, keyboardType: TextInputType.emailAddress),
                            const SizedBox(height: 15),
                            _buildPasswordField("ពាក្យសម្ងាត់", _passwordController, _isPasswordVisible, () => setState(() => _isPasswordVisible = !_isPasswordVisible)),
                            const SizedBox(height: 15),
                            _buildPasswordField("បញ្ជាក់ពាក្យសម្ងាត់", _confirmPasswordController, _isConfirmPasswordVisible, () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible)),
                            const SizedBox(height: 25),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                              onPressed: _isLoading ? null : _registerUser,
                              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("យល់ព្រមចុះឈ្មោះ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                            const SizedBox(height: 15),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text("មានគណនីរួចហើយ? ចូល", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                            ),

                            // 🔹 បញ្ចូលរបារភ្ជាប់គណនី និងប៊ូតុងសង្គមទាំង៣
                            const SizedBox(height: 25),
                            Row(
                              children: [
                                Expanded(child: Divider(color: Colors.grey[300])),
                                const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("ឬចុះឈ្មោះជាមួយ", style: TextStyle(color: Colors.grey, fontSize: 12))),
                                Expanded(child: Divider(color: Colors.grey[300])),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSocialButton(Icons.g_mobiledata, const Color(0xFFEA4335), _signInWithGoogle),
                                const SizedBox(width: 20),
                                _buildSocialButton(Icons.facebook, const Color(0xFF1877F2), _signInWithFacebook),
                                const SizedBox(width: 20),
                                _buildSocialButton(FontAwesomeIcons.tiktok, Colors.black, _signInWithTikTok),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.grey[100],
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey[300]!)),
          child: Icon(icon, color: color, size: 30),
        ),
      ),
    );
  }

  Widget _buildField(String label, IconData icon, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller, keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey[100]),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool isVisible, VoidCallback onToggle) {
    return TextField(
      controller: controller, obscureText: !isVisible,
      decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.lock), suffixIcon: IconButton(icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off), onPressed: onToggle), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey[100]),
    );
  }
}