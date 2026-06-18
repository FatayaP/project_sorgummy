import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Center(
          // PEMBATAS DESKTOP: Mengunci lebar maksimal konten agar tidak melar raksasa
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 360.0, // Ukuran standar lebar layar HP
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Farmer Illustration Image
                  Image.asset(
                    'assets/images/farmer.png',
                    height: 220.0, // Disesuaikan sedikit agar proporsinya pas
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 220.0,
                      width: 220.0,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50, 
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.agriculture, 
                        size: 90.0, 
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  
                  // Teks Judul
                  const Text(
                    'Hallo, Petani Hebat! 🌱',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.0, 
                      fontWeight: FontWeight.bold, 
                      color: AppColors.textCharcoal,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  
                  // Teks Deskripsi
                  const Text(
                    'Belajar, bertanya, dan temukan soluciones terbaik untuk budidaya sorgum bersama Sorgummi AI.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.0, 
                      color: AppColors.textLight, 
                      height: 1.4,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // AREA TOMBOL AKSI (Ukurannya konsisten di mobile & desktop)
                  Column(
                    children: [
                      // Masuk Button
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          minimumSize: const Size(double.infinity, 48.0), // Tinggi proporsional 48
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0), // Melengkung kapsul sempurna
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        ),
                        child: const Text(
                          'Masuk', 
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      
                      const SizedBox(height: 12.0), // Jarak ideal antar tombol
                      
                      // Daftar Akun Button
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.dividerGrey, width: 1.5),
                          minimumSize: const Size(double.infinity, 48.0), // Tinggi seimbang 48
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        ),
                        child: const Text(
                          'Daftar Akun', 
                          style: TextStyle(
                            fontSize: 16.0, 
                            color: AppColors.textCharcoal, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24.0), // Jarak aman dasar bawah
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}