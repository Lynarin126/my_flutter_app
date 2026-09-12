import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'RegisterScreen.dart';
import 'HomeScreen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe      = true;
  bool _isLoading       = false;

  int _failedAttempts = 0;
  int _lockoutStage = 0;
  DateTime? _lockoutUntil;

  // 🔹 មុខងារផ្ញើអ៊ីមែលកំណត់ពាក្យសម្ងាត់ឡើងវិញ (Forgot Password)
  Future<void> _handleForgotPassword() async {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("ភ្លេចពាក្យសម្ងាត់?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "សូមបញ្ចូលអ៊ីមែលរបស់អ្នកដើម្បីទទួលបានតំណភ្ជាប់ (Link) សម្រាប់កំណត់ពាក្យសម្ងាត់ឡើងវិញ៖",
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "អ៊ីមែល",
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("បោះបង់"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3A7FD5)),
            onPressed: () async {
              String email = emailController.text.trim();
              if (email.isEmpty) {
                _showMessage("សូមបញ្ចូលអ៊ីមែលរបស់អ្នក!", isError: true);
                return;
              }

              Navigator.pop(context); // បិទ Dialog
              setState(() => _isLoading = true);

              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                _showMessage("តំណភ្ជាប់សម្រាប់កំណត់ពាក្យសម្ងាត់ថ្មីត្រូវបានផ្ញើទៅកាន់អ៊ីមែលរបស់អ្នកហើយ!", isError: false);
              } on FirebaseAuthException catch (e) {
                String errorMsg = "មិនអាចផ្ញើអ៊ីមែលបានទេ";
                if (e.code == 'user-not-found') {
                  errorMsg = "រកមិនឃើញគណនីដែលមានអ៊ីមែលនេះឡើយ!";
                } else if (e.code == 'invalid-email') {
                  errorMsg = "ទម្រង់អ៊ីមែលមិនត្រឹមត្រូវទេ!";
                }
                _showMessage(errorMsg, isError: true);
              } catch (e) {
                _showMessage("មានកំហុសកើតឡើង៖ ${e.toString()}", isError: true);
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text("ផ្ញើ Link", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 🔹 មុខងារចូលប្រើប្រាស់គណនី (Login) រួមជាមួយការឆែកការចាក់សោ
  Future<void> _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // 1. Validation ពិនិត្យមើល Input
    if (email.isEmpty || password.isEmpty) {
      _showMessage("សូមបញ្ចូលអ៊ីមែល និងពាក្យសម្ងាត់!", isError: true);
      return;
    }

    // 🔹 ពិនិត្យមើលការចាក់សោ និងបង្ហាញរយៈពេលដែលនៅសល់
    if (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)) {
      final remainingSeconds = _lockoutUntil!.difference(DateTime.now()).inSeconds;
      String timeMsg;
      if (remainingSeconds < 60) {
        timeMsg = "$remainingSeconds វិនាទី";
      } else {
        final remainingMinutes = (remainingSeconds / 60).ceil();
        timeMsg = "$remainingMinutes នាទី";
      }
      _showMessage("គណនីត្រូវបានចាក់សោរជាបណ្តោះអាសន្ន! សូមព្យាយាមម្តងទៀតនៅ $timeMsg ក្រោយ។", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. ចូលប្រើប្រាស់តាមរយៈ Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      // 3. ទាញយកទិន្នន័យអ្នកប្រើប្រាស់ពី Cloud Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // 🔹 ចូលបានជោគជ័យ កំណត់ការចាក់សោ និងដំណាក់កាលទៅ 0 វិញទាំងអស់
        setState(() {
          _failedAttempts = 0;
          _lockoutStage = 0;
          _lockoutUntil = null;
        });

        if (mounted) {
          _showMessage("ការចូលប្រើប្រាស់ជោគជ័យ!", isError: false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(userData: userData),
            ),
          );
        }
      } else {
        _showMessage("រកមិនឃើញទិន្នន័យក្នុងប្រព័ន្ធទេ!", isError: true);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "ការចូលប្រើប្រាស់បរាជ័យ";
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        setState(() {
          _failedAttempts++;
          if (_failedAttempts >= 3) {
            _lockoutStage++; // កើនឡើង ១ ដំណាក់កាល

            Duration lockoutDuration;
            String lockoutTimeText;

            // កំណត់រយៈពេលចាក់សោតាមដំណាក់កាលនីមួយៗ
            if (_lockoutStage == 1) {
              lockoutDuration = const Duration(seconds: 30);
              lockoutTimeText = "៣០ វិនាទី";
            } else if (_lockoutStage == 2) {
              lockoutDuration = const Duration(minutes: 2);
              lockoutTimeText = "២ នាទី";
            } else {
              lockoutDuration = const Duration(minutes: 5);
              lockoutTimeText = "៥ នាទី";
            }

            _lockoutUntil = DateTime.now().add(lockoutDuration);
            _failedAttempts = 0; // reset ចំនួនដងដើម្បីរាប់សារថ្មីក្រោយពេលដោះសោ

            errorMessage = "អ្នកបានបញ្ចូលខុស ៣ ដង! គណនីត្រូវបានផ្អាករយៈពេល $lockoutTimeText (ដំណាក់កាលទី $_lockoutStage)។";
          } else {
            errorMessage = "អ៊ីមែល ឬ ពាក្យសម្ងាត់មិនត្រឹមត្រូវទេ! (ខុសចំនួន $_failedAttempts / ៣ ដង)";
          }
        });
      } else if (e.code == 'invalid-email') {
        errorMessage = "ទម្រង់អ៊ីមែលមិនត្រឹមត្រូវឡើយ!";
      }
      _showMessage(errorMessage, isError: true);
    } catch (e) {
      _showMessage("កើតមានកំហុស៖ ${e.toString()}", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SizedBox(
        width: double.infinity,
        height: screenHeight,
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/bg_login.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue.shade300,
                          Colors.blue.shade100,
                          Colors.lightBlue.shade50,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.05),
              ),
            ),

            // Content
            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 60),

                        // Logo
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade200,
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.home_work_rounded,
                            size: 65,
                            color: Color(0xFF3A7FD5),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Title
                        const Text(
                          "សូមស្វាគមន៍មកកាន់ប្រពន័្ធ \nគ្រប់គ្រងការជួលបន្ទប់",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Fasthand',
                            fontWeight: FontWeight.w800,
                            fontSize: 26,

                            color: Color(0xFF1A3F6F),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Login to your account",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Form Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Email
                                TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: "អ៊ីមែល",
                                    hintStyle: const TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                    prefixIcon: const Icon(Icons.email_outlined,
                                        color: Color(0xFF3A7FD5)),
                                    filled: true,
                                    fillColor: const Color(0xFFF0F6FF),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF3A7FD5), width: 1.5),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Password
                                TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    hintText: "ពាក្យសម្ងាត់",
                                    hintStyle: const TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                    prefixIcon: const Icon(Icons.lock_outline,
                                        color: Color(0xFF3A7FD5)),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF0F6FF),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF3A7FD5), width: 1.5),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Remember Me + Forgot Password
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            onChanged: (val) => setState(
                                                    () => _rememberMe = val!),
                                            activeColor:
                                            const Color(0xFF3A7FD5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          "Remember Me",
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: _handleForgotPassword, // 🔹 ហៅប្រើមុខងារ Forgot Password
                                      style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero),
                                      child: const Text(
                                        "ភ្លេចពាក្យសម្ងាត់?",
                                        style: TextStyle(
                                            color: Color(0xFF3A7FD5),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Login Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3A7FD5),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 4,
                                      shadowColor: Colors.blue.shade300,
                                    ),
                                    onPressed: _isLoading ? null : _handleLogin,
                                    child: _isLoading
                                        ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                        : const Text(
                                      "ចូលប្រើគណនី",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Register Link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "មិនទាន់មានគណនីទេ?",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 13),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const RegisterScreen()),
                                      ),
                                      style: TextButton.styleFrom(
                                          padding:
                                          const EdgeInsets.only(left: 4)),
                                      child: const Text(
                                        "ចូលចុះឈ្មោះ!",
                                        style: TextStyle(
                                          color: Color(0xFF3A7FD5),
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
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
          ],
        ),
      ),
    );
  }
}
