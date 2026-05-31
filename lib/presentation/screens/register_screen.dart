import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _rememberMe = false;
  bool _obscurePassword = true;

  void _doRegister() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Tombol Back di pojok kiri atas
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF263238)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360.0),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(), // Tetap terkunci statis (anti-scroll)
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  // 1. Gambar Ilustrasi (Ukurannya disesuaikan agar hemat ruang)
                  Center(
                    child: Image.asset(
                      'assets/images/register_illustration.png',
                      height: 120.0,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120.0,
                          width: 120.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7F5),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: const Icon(Icons.app_registration_rounded, size: 60.0, color: AppColors.primaryGreen),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12.0),

                  // 2. Header Teks
                  const Text(
                    'Register',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20), letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Please register to login.',
                    style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),

                  // 3. Input Username
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Username',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.grey, size: 22),
                      filled: true,
                      fillColor: const Color(0xFFF5F6F9),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 4. Input Mobile Number
                  TextField(
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Mobile Number',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon: const Icon(Icons.phone_outlined, color: Colors.grey, size: 22),
                      filled: true,
                      fillColor: const Color(0xFFF5F6F9),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 5. Input Password
                  TextField(
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 22),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey, size: 18),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F6F9),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 6. Reminder Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reminder me nextime',
                        style: TextStyle(color: Color(0xFF263238), fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      Transform.scale(
                        scale: 0.75,
                        child: Switch(
                          value: _rememberMe,
                          activeColor: Colors.white,
                          activeTrackColor: AppColors.primaryGreen,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.grey.shade300,
                          onChanged: (bool value) {
                            setState(() {
                              _rememberMe = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 7. Tombol Sign Up Utama
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      minimumSize: const Size(double.infinity, 46.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23.0)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      _doRegister();
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 8. Teks "Already have account? Sign In" (Dinaikkan jaraknya agar pas dan kelihatan jelas)
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 13, color: Colors.grey, fontFamily: 'sans-serif'),
                          children: [
                            TextSpan(text: "Already have account? "),
                            TextSpan(
                              text: 'Sign In', 
                              style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}