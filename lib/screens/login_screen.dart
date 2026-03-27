import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'forgot_screen.dart'; // Import halaman Lupa Akses yang baru dibuat

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081C15),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image (Tanaman Sorgum)
          Positioned.fill(
            child: Image.network(
              'https://i.pinimg.com/736x/c4/e9/ba/c4e9bad57f2f1facbbd73aa554e9251c.jpg', // Ganti dengan asset lokal jika Anda punya gambarnya
              fit: BoxFit.cover,
            ),
          ),

          // 2. Gradient Overlay (Diatur agar transparan di tengah seperti gambar)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8), // Gelap di atas untuk teks HALO
                    Colors.black.withOpacity(0.3), // Terang di tengah agar sorgum terlihat
                    Colors.black.withOpacity(0.9), // Gelap di bawah untuk teks footer
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // 3. Header Text (Kiri Atas)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 32, right: 32, top: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 42, // Diperbesar sesuai referensi gambar
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: -1.0,
                        ),
                        children: [
                          TextSpan(
                            text: 'HALO\n',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: 'KEMBALI!',
                            style: TextStyle(color: Color(0xFFD4A373)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'PORTAL DIGITAL PECINTA SORGUM',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Form Transparan di Tengah
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                margin: const EdgeInsets.only(top: 120), // Memberi jarak dari header
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Input Username
                    TextFormField(
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Username',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.08),
                        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFD4A373), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Input Password
                    TextFormField(
                      obscureText: true,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.08),
                        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFD4A373), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Baris INGAT SAYA & LUPA AKSES
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _rememberMe = !_rememberMe;
                            });
                          },
                          child: Row(
                            children: [
                              // Kotak Checkbox (Disamakan dengan gambar referensi)
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: Colors.white,
                                  checkColor: Colors.black,
                                  fillColor: MaterialStateProperty.resolveWith((states) {
                                    if (states.contains(MaterialState.selected)) {
                                      return Colors.white;
                                    }
                                    return Colors.transparent;
                                  }),
                                  side: const BorderSide(color: Colors.white, width: 2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'INGAT SAYA',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Navigasi ke Layar ForgotScreen
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotScreen()));
                          },
                          child: const Text(
                            'LUPA AKSES?',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFFD4A373),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Tombol MASUK KE APLIKASI
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implementasi Aksi Login
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1B4332),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'MASUK KE APLIKASI',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1B4332),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Footer DAFTAR
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text: 'BELUM PUNYA AKUN? ',
                              style: TextStyle(color: Colors.white54),
                            ),
                            TextSpan(
                              text: 'DAFTAR',
                              style: TextStyle(
                                color: Color(0xFFD4A373),
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFFD4A373),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}