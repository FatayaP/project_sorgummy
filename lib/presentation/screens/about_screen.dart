import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false), // Sembunyikan scrollbar web kaku
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: AppBar(
          title: const Text(
            'Tentang Sorgummi AI', 
            style: TextStyle(color: AppColors.textCharcoal, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white, 
          centerTitle: true,
          leading: const BackButton(color: AppColors.textCharcoal),
          elevation: 0,
          // Garis pembatas bawah tipis agar konsisten dengan tema halaman profil lainnya
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: AppColors.cardLightGrey, height: 1.0),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: double.infinity), // Lebar penuh responsif
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // KUNCI UTAMA: Menampilkan logo.png asli proyekmu dengan dekorasi bingkai halus
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24), // Sudut melengkung halus yang estetik
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 110,
                        width: 110,
                        fit: BoxFit.contain,
                        // Fallback cadangan jika file logo.png belum dimasukkan ke pubspec.yaml
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 110,
                          width: 110,
                          color: Colors.green.shade50,
                          child: const Icon(Icons.eco_rounded, size: 60, color: AppColors.primaryGreen),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Sorgummi AI', 
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textCharcoal, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Versi 1.0.0', 
                      style: TextStyle(color: AppColors.textLight, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 32),
                    
                    // Kolom Deskripsi Aplikasi Premium
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardLightGrey, width: 1),
                      ),
                      child: const Text(
                        'Sorgummi AI merupakan platform aplikasi cerdas yang dirancang khusus untuk memberikan edukasi interaktif dan solusi pengelolaan budidaya tanaman sorgum berbasis Artificial Intelligence. Fokus utama kami adalah membantu mengoptimalkan potensi sorgum demi ketahanan pangan masa depan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textCharcoal, fontSize: 14, height: 1.6),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    const Text(
                      '© 2026 Sorgummi Team. All Rights Reserved.',
                      style: TextStyle(color: AppColors.textLight, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}