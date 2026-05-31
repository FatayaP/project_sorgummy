import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../data/helpers/shared_prefs_helper.dart';
import 'main_navigation.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;
  bool _obscurePassword = true;

  void _doLogin() async {
    await SharedPrefsHelper.setLoggedIn(true);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 1. Tombol Back di pojok kiri atas tetap dipertahankan
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
              // Terkunci statis (anti-scroll) tapi bebas dari eror RenderFlex kuning-hitam
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  // 2. Gambar Ilustrasi Login (Ukurannya pas agar hemat ruang)
                  Center(
                    child: Image.asset(
                      'assets/images/login_illustration.png', // Path aset gambar login Anda
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
                          child: const Icon(Icons.security, size: 60.0, color: AppColors.primaryGreen),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12.0),

                  // 3. Header Teks (Tema Hijau Khas Sorgummi)
                  const Text(
                    'Login',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20), letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Please Sign in to continue.',
                    style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),

                  // 4. Input Username
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

                  // 5. Input Password dengan Fitur Toggle Visibility
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

                  // 6. Reminder Switch (Warna Hijau Tema)
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

                  // 7. Tombol Sign In Utama
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      minimumSize: const Size(double.infinity, 46.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23.0)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      _doLogin();
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 8. Teks Footer "Don't have account? Sign Up" (Aman, tidak tenggelam bawah layar)
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 13, color: Colors.grey, fontFamily: 'sans-serif'),
                          children: [
                            TextSpan(text: "Don't have account? "),
                            TextSpan(
                              text: 'Sign Up', 
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