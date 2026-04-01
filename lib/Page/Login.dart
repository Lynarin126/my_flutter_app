import 'package:flutter/material.dart';
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

  void _handleLogin() {
    String username = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (username == "Admin" && password == "123") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ការចូលប្រើប្រាស់ជោគជ័យ!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ឈ្មោះអ្នកប្រើ ឬ ពាក្យសម្ងាត់មិនត្រឹមត្រូវ!"),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      // ✅ resizeToAvoidBottomInset ការពារ Keyboard
      resizeToAvoidBottomInset: true,
      body: SizedBox(
        width: double.infinity,
        height: screenHeight,
        child: Stack(
          children: [

            // ============================
            // ✅ Background Image ពេញ Screen
            // ============================
            Positioned.fill(
              child: Image.asset(
                'assets/images/bg_login.png',
                fit: BoxFit.cover, // ពេញ Screen
                errorBuilder: (context, error, stackTrace) {
                  // ✅ បើរូបអត់មាន → ប្រើ Gradient ជំនួស
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

            // ============================
            // ✅ Overlay តែបន្តិច
            // ============================
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.05),
              ),
            ),

            // ============================
            // ✅ Content នៅកណ្តាល Screen
            // ============================
            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    // ✅ យ៉ាងតិចត្រូវ screenHeight ដើម្បីគ្មានចន្លោះ
                    minHeight: screenHeight -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 60),

                        // ============================
                        // Logo
                        // ============================
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
                          "សូមស្វាគមន៍មកកាន់ប្រពន្ធ័ \nគ្រប់គ្រងការជួលបន្ទប់",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
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

                        // ============================
                        // Form Card
                        // ============================
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                  Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [

                                // Username
                                TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    hintText: "ឈ្មោះអ្នកប្រើប្រាស់",
                                    hintStyle: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14),
                                    prefixIcon: const Icon(
                                        Icons.person_outline,
                                        color: Color(0xFF3A7FD5)),
                                    filled: true,
                                    fillColor:
                                    const Color(0xFFF0F6FF),
                                    contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF3A7FD5),
                                          width: 1.5),
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
                                        color: Colors.grey,
                                        fontSize: 14),
                                    prefixIcon: const Icon(
                                        Icons.lock_outline,
                                        color: Color(0xFF3A7FD5)),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons
                                            .visibility_off_outlined
                                            : Icons
                                            .visibility_outlined,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () => setState(() =>
                                      _obscurePassword =
                                      !_obscurePassword),
                                    ),
                                    filled: true,
                                    fillColor:
                                    const Color(0xFFF0F6FF),
                                    contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF3A7FD5),
                                          width: 1.5),
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
                                            onChanged: (val) =>
                                                setState(() =>
                                                _rememberMe =
                                                val!),
                                            activeColor: const Color(
                                                0xFF3A7FD5),
                                            shape:
                                            RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(4),
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
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero),
                                      child: const Text(
                                        "ភ្លេចពាក្យសម្ងាត់?",
                                        style: TextStyle(
                                            color: Color(0xFF3A7FD5),
                                            fontSize: 13,
                                            fontWeight:
                                            FontWeight.w600),
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
                                      backgroundColor:
                                      const Color(0xFF3A7FD5),
                                      padding:
                                      const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(14),
                                      ),
                                      elevation: 4,
                                      shadowColor:
                                      Colors.blue.shade300,
                                    ),
                                    onPressed: _handleLogin,
                                    child: const Text(
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
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "មិនទាន់មានគណនីទេ?",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                const RegisterScreen()),
                                          ),
                                      style: TextButton.styleFrom(
                                          padding:
                                          const EdgeInsets.only(
                                              left: 4)),
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

                        // ✅ Spacer ទំនេរ ពេញ Space ខាងក្រោម
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