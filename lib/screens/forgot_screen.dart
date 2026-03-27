import 'package:flutter/material.dart';
import 'dart:ui';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  // State untuk melacak apakah tombol kirim email sudah ditekan
  bool _emailSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081C15),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image (dengan opacity 30% dan diperbesar/scale-125)
          Positioned.fill(
            child: Transform.scale(
              scale: 1.25,
              child: Opacity(
                opacity: 0.3,
                child: Image.network(
                  'https://images.unsplash.com/photo-1473976144073-61b402127271?auto=format&fit=crop&q=80&w=1000',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 2. Gradient Overlay (Gelap di atas dan bawah, transparan di tengah)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF081C15),
                    Colors.transparent,
                    const Color(0xFF081C15),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // 3. Konten Utama
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 32, right: 32, top: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // Tombol Kembali (Glassmorphism)
                  Container(
                    margin: const EdgeInsets.only(bottom: 40),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context); // Kembali ke halaman Login
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05), // bg-white/5
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1), // border-white/10
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Header Teks
                  Container(
                    margin: const EdgeInsets.only(bottom: 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 30, // text-3xl
                              fontWeight: FontWeight.w900, // font-black
                              height: 1.1, // leading-tight
                              letterSpacing: -1.5, // tracking-tighter
                            ),
                            children: [
                              TextSpan(
                                text: 'PEMULIHAN\n',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(
                                text: 'AKSES.',
                                style: TextStyle(color: Color(0xFFD4A373)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 200, // max-w-[200px]
                          child: Text(
                            'KAMI AKAN MENGIRIMKAN INSTRUKSI KE EMAIL TERDAFTAR ANDA',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3.0, // tracking-[0.3em]
                              height: 1.6, // leading-relaxed
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Animasi Transisi (Tampil Form ATAU Tampil Sukses)
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500), // durasi animasi setara duraton-500
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeOut,
                      child: !_emailSent ? _buildForm() : _buildSuccess(),
                    ),
                  ),

                  // Footer Security Protocol di bawah layar (mt-auto)
                  Container(
                    padding: const EdgeInsets.only(bottom: 24),
                    width: double.infinity,
                    child: Text(
                      'SORGUMCARE SECURITY PROTOCOL • V2.1',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.2), // text-white/20
                        fontSize: 9, // text-[9px]
                        fontWeight: FontWeight.bold, // font-bold
                        letterSpacing: 2.0, // tracking-[0.2em]
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET 1: Tampilan Form Input Email
  Widget _buildForm() {
    return Column(
      key: const ValueKey('form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field Input Email dengan Ikon
        TextFormField(
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(Icons.mail_outline, color: Colors.white.withOpacity(0.3), size: 18),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 46),
            hintText: 'Masukkan Email Terdaftar',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05), // bg-white/5
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD4A373)),
            ),
          ),
        ),
        const SizedBox(height: 24), // space-y-6

        // Tombol "Atur Ulang Kata Sandi"
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // shadow-xl
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            borderRadius: BorderRadius.circular(16),
          ),
          child: ElevatedButton(
            onPressed: () {
              // Mengubah state untuk memicu animasi ke tampilan Sukses
              setState(() {
                _emailSent = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A373),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.autorenew, size: 18), // setara dengan lucide RefreshCw
                SizedBox(width: 12),
                Text(
                  'ATUR ULANG KATA SANDI',
                  style: TextStyle(
                    fontSize: 11, // text-[11px]
                    fontWeight: FontWeight.w900, // font-black
                    letterSpacing: 3.0, // tracking-widest
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // WIDGET 2: Tampilan Sukses (Email Terkirim)
  Widget _buildSuccess() {
    return Center(
      key: const ValueKey('success'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ikon Lingkaran Send
          Container(
            width: 80, // w-20
            height: 80, // h-20
            margin: const EdgeInsets.only(bottom: 24), // mb-6
            decoration: BoxDecoration(
              color: const Color(0xFFD4A373).withOpacity(0.2), // bg-[#D4A373]/20
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 48, // w-12
                height: 48, // h-12
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A373), // bg-[#D4A373]
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4A373).withOpacity(0.3), // shadow-[#D4A373]/30
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ),

          // Teks Sukses
          const Text(
            'EMAIL TERKIRIM!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18, // text-lg
              fontWeight: FontWeight.w900, // font-black
              letterSpacing: 3.0, // tracking-widest
            ),
          ),
          const SizedBox(height: 12), // mt-3

          // Subtitle Bawah Teks Sukses
          SizedBox(
            width: 250, // max-w-[250px]
            child: Text(
              'Silakan periksa kotak masuk email Anda untuk melanjutkan pemulihan akun.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5), // text-white/50
                fontSize: 12, // text-xs
                height: 1.6, // leading-relaxed
              ),
            ),
          ),
          const SizedBox(height: 40), // mt-10

          // Hyperlink Kembali ke Login
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // Kembali ke Login
            },
            child: const Text(
              'KEMBALI KE LOGIN',
              style: TextStyle(
                color: Color(0xFFD4A373), // text-[#D4A373]
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 3.0, // tracking-[0.3em]
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFFD4A373),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
