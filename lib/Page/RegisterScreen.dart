import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // ✅ Gradient Background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              // ✅ FIX: បំពេញអោយពេញ screen (លុបចន្លោះក្រោម)
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // 🏷 Title
                    const Text(
                      "បង្កើតគណនីថ្មី",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ✅ Card Form
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildField("ឈ្មោះពេញ", Icons.person),
                            const SizedBox(height: 15),
                            _buildField("លេខទូរស័ព្ទ", Icons.phone),
                            const SizedBox(height: 15),
                            _buildField("អ៊ីមែល", Icons.email),
                            const SizedBox(height: 15),

                            _buildPasswordField(
                              "ពាក្យសម្ងាត់",
                              _isPasswordVisible,
                                  () {
                                setState(() => _isPasswordVisible =
                                !_isPasswordVisible);
                              },
                            ),
                            const SizedBox(height: 15),

                            _buildPasswordField(
                              "បញ្ជាក់ពាក្យសម្ងាត់",
                              _isConfirmPasswordVisible,
                                  () {
                                setState(() =>
                                _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible);
                              },
                            ),

                            const SizedBox(height: 25),

                            // 🔵 Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(0xFF2196F3),
                                minimumSize:
                                const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {},
                              child: const Text(
                                "យល់ព្រមចុះឈ្មោះ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "មានគណនីរួចហើយ? ចូល",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                    const Spacer(), // 👉 កុំអោយមាន space ខាងក្រោម
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 TextField
  Widget _buildField(String label, IconData icon) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  // 🔹 Password Field
  Widget _buildPasswordField(
      String label, bool isVisible, VoidCallback onToggle) {
    return TextField(
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}