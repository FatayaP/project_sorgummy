import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../data/helpers/shared_prefs_helper.dart';
import 'welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  // 1. DAFTAR DATA DINAMIS (Gambar & Teks berbeda tiap halaman)
  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Sorgummi AI',
      'subtitle': 'Edukasi & Solusi\nSorgum Berbasis AI',
      'image': 'assets/images/sorghum_bg.png', // Gambar slide 1
    },
    {
      'title': 'Pantau Budidaya',
      'subtitle': 'Manajemen Pengelolaan\nSecara Mudah & Real-Time',
      'image': 'assets/images/sorghum_bgg.png', // Gantilah dengan gambar slide 2 Anda
    },
    {
      'title': 'Hasil Maksimal',
      'subtitle': 'Optimalkan Kualitas Panen\nBersama Teknologi AI',
      'image': 'assets/images/banner_bg.png', // Gantilah dengan gambar slide 3 Anda
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding(BuildContext context) async {
    await SharedPrefsHelper.setFirstTime(false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background Langit Gradasi Alamiah (Statis di paling belakang)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE3F2FD), 
                    Color(0xFFF1F8E9), 
                  ],
                ),
              ),
            ),
          ),

          // Konten Dinamis (PageView) - Gambar dan Teks Berubah Saat Di-slide
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _onboardingData.length,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                final currentItem = _onboardingData[index];

                return Stack(
                  children: [
                    // Gambar Tanaman yang Berubah-ubah sesuai list data
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: screenSize.height * 1, 
                      child: Image.asset(
                        currentItem['image']!, // Memanggil gambar dinamis
                        fit: BoxFit.cover,
                        alignment: const Alignment(0.0, 0.2),
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback jika file gambar 2 atau 3 belum ada di assets Anda
                          return Image.asset(
                            'assets/images/sorghum_bg.png', // Pakai gambar utama sebagai cadangan
                            fit: BoxFit.cover,
                            alignment: const Alignment(0.0, 0.2),
                          );
                        },
                      ),
                    ),

                    // Lapisan Konten Teks dan Logo di Atas Gambar
                    Positioned.fill(
                      child: SafeArea(
                        child: Column(
                          children: [
                            const SizedBox(height: 30.0),
                            
                            // Logo Ilustrasi Tanaman Sorgum
                            Image.asset(
                              'assets/images/logo.png',
                              height: 85.0,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.eco,
                                  color: AppColors.primaryGreen,
                                  size: 65.0,
                                );
                              },
                            ),
                            const SizedBox(height: 16.0),

                            // Judul Utama yang Berubah-ubah
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 34.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                  fontFamily: 'sans-serif',
                                ),
                                children: [
                                  TextSpan(
                                    text: '${currentItem['title']!.split(' ')[0]} ',
                                    style: const TextStyle(color: Color(0xFF1B5E20)), 
                                  ),
                                  if (currentItem['title']!.split(' ').length > 1)
                                    TextSpan(
                                      text: currentItem['title']!.split(' ')[1],
                                      style: const TextStyle(color: Color(0xFF4CAF50)), 
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8.0),

                            // Deskripsi / Tagline Halaman Dinamis
                            Text(
                              currentItem['subtitle']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF263238), 
                                  height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Baris Indikator Tetap & Tombol Navigasi dengan Bayangan Halus
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: screenSize.height * 0.13 > 90.0 ? screenSize.height * 0.13 : 90.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  topRight: Radius.circular(50.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03), 
                    blurRadius: 15.0,
                    spreadRadius: 0.0,
                    offset: const Offset(0, -6), 
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Baris Titik Indikator Otomatis Berubah
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => _buildDot(index == _currentPage),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  
                  // Tombol Navigasi Lanjut / Mulai
                  TextButton(
                    onPressed: () {
                      if (_currentPage == _onboardingData.length - 1) {
                        _finishOnboarding(context);
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      minimumSize: const Size(120.0, 36.0),
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _currentPage == _onboardingData.length - 1 ? 'Mulai' : 'Lanjut',
                      style: const TextStyle(
                        color: Color(0xFF558B2F), 
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
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

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 5.0, 
      width: isActive ? 26.0 : 12.0,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF689F38) : const Color(0xFFCFD8DC),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }
}