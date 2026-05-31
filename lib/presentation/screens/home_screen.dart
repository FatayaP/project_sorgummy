import 'dart:convert'; // Untuk decode base64 gambar
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/colors.dart';
import 'chat_screen.dart';
import 'pengelolaan_screen.dart';
import 'notification_screen.dart';
import 'search_screen.dart';
import 'edukasi_screen.dart';
import 'artikel_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _homeBase64Image; // Sinkronisasi gambar via SharedPreferences

  List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Peringatan Cuaca',
      'desc': 'Hujan lebat diprediksi besok, amankan lahan Anda.',
      'detail': 'Berdasarkan data BMKG terbaru, wilayah Anda berpotensi mengalami hujan lebat disertai angin kencang besok pagi. Pastikan saluran drainase di sekitar lahan sorgum tidak tersumbat untuk mencegah genangan air berlebih.',
      'time': 'Baru saja',
      'isUnread': true,
      'icon': Icons.thunderstorm_rounded,
    },
    {
      'id': '2',
      'title': 'Artikel Baru',
      'desc': 'Baca panduan pemupukan sorgum terbaru kami!',
      'detail': 'Kami baru saja menerbitkan artikel mengenai formulasi pupuk NPK yang optimal untuk fase vegetatif tanaman sorgum. Pelajari teknik pengaplikasiannya sekarang untuk meningkatkan bobot malai panen Anda.',
      'time': '2 jam lalu',
      'isUnread': true,
      'icon': Icons.menu_book_rounded,
    },
    {
      'id': '3',
      'title': 'Jadwal Pupuk',
      'desc': 'Waktunya memberikan pupuk pada blok A kebun Anda.',
      'detail': 'Kalender pengelolaan mencatat hari ini adalah jadwal pemupukan susulan tahap kedua untuk tanaman sorgum di Blok A (usia 30 HST). Gunakan dosis rekomendasi yang tertera pada modul kelola.',
      'time': 'Kemarin',
      'isUnread': false,
      'icon': Icons.science_rounded,
    },
  ];

  final List<Map<String, String>> _edukasiTerbaru = const [
    {
      'title': 'Panduan Pemupukan Sorgum yang Tepat',
      'subtitle': 'Tingkatkan hasil panen dengan teknik pemupukan ini.',
      'date': '31 Mei 2026',
      'image': 'assets/images/pemupukan.png',
      'url': 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?auto=format&fit=crop&w=150&q=80',
    },
    {
      'title': 'Cara Mengatasi Penyakit Daun Menguning',
      'subtitle': 'Kenali penyebab dan solusi cepat mengatasinya.',
      'date': '28 Mei 2026',
      'image': 'assets/images/daun_kuning.png',
      'url': 'https://images.unsplash.com/photo-1530836369250-ef71a3f5e48d?auto=format&fit=crop&w=150&q=80',
    },
    {
      'title': 'Persiapan Lahan Ideal untuk Benih',
      'subtitle': 'Langkah awal untuk pertumbuhan tanaman yang sehat.',
      'date': '25 Mei 2026',
      'image': 'assets/images/persiapan_lahan.png',
      'url': 'https://images.unsplash.com/photo-1592982537447-6f29cb91cb8e?auto=format&fit=crop&w=150&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadHomeProfileImage();
  }

  // Ambil gambar secara lokal dari device saat aplikasi dibuka kembali
  Future<void> _loadHomeProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _homeBase64Image = prefs.getString('user_profile_image');
    });
  }

  Future<void> _navigateToNotification() async {
    final updatedNotifications = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationScreen(initialNotifications: _notifications),
      ),
    );

    if (updatedNotifications != null) {
      setState(() {
        _notifications = updatedNotifications;
      });
    }
  }

  // Fungsi navigasi yang otomatis me-refresh image state saat kembali dari ProfileScreen
  Future<void> _navigateToProfile() async {
    final checkRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );

    if (checkRefresh == true) {
      _loadHomeProfileImage();
    }
  }

  ImageProvider? _getAvatarImage() {
    if (_homeBase64Image != null && _homeBase64Image!.isNotEmpty) {
      return MemoryImage(base64Decode(_homeBase64Image!));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasUnreadNotifications = _notifications.any((notif) => notif['isUnread'] == true);

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: double.infinity,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _navigateToProfile,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                                backgroundImage: _getAvatarImage(),
                                child: _getAvatarImage() == null
                                    ? const Icon(Icons.person_rounded, color: AppColors.primaryGreen, size: 22)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Halo, Petani Hebat 👋', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textCharcoal)),
                                Text('Semangat belajar hari ini!', style: TextStyle(fontSize: 13, color: AppColors.textLight)),
                              ],
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: _navigateToNotification,
                          child: Stack(
                            children: [
                              const Icon(Icons.notifications_none, color: AppColors.textCharcoal, size: 30),
                              if (hasUnreadNotifications)
                                Positioned(
                                  right: 2, 
                                  top: 2, 
                                  child: Container(
                                    width: 10, 
                                    height: 10, 
                                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(color: AppColors.cardLightGrey, borderRadius: BorderRadius.circular(50)),
                      child: TextField(
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen(query: value)));
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari edukasi, pengelolaan, dll...',
                          hintStyle: TextStyle(color: AppColors.textLight.withOpacity(0.7), fontSize: 13),
                          prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/banner_bg.png'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken), 
                        ),
                        color: AppColors.primaryGreen, 
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kenali Potensi\nSorgum untuk\nMasa Depan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              elevation: 0,
                            ),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArtikelScreen())),
                            child: const Text('Baca Selengkapnya', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text('Menu Utama', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textCharcoal)),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.88, 
                      children: [
                        _buildMenuItem(context, null, Icons.smart_toy, 'Chat AI', 'Tanya apa saja\nseputar sorgum', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
                        _buildMenuItem(context, null, Icons.menu_book, 'Edukasi', 'Belajar budidaya\nsorgum', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EdukasiScreen()))),
                        _buildMenuItem(context, null, Icons.eco, 'Pengelolaan', 'Panduan pengelolaan\nsorgum', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PengelolaanScreen()))),
                        _buildMenuItem(context, null, Icons.article, 'Artikel', 'Informasi & berita\nterbaru', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArtikelScreen()))),
                        _buildMenuItem(context, null, Icons.notifications_active, 'Notifikasi', 'Update & info\npenting', _navigateToNotification),
                        _buildMenuItem(
                          context, 
                          _getAvatarImage(), 
                          Icons.person, 
                          'Profil', 
                          'Akun & pengaturan\nanda', 
                          _navigateToProfile
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Edukasi Terbaru 🌱', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textCharcoal)),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EdukasiScreen())),
                          child: const Text('Lihat Semua', style: TextStyle(fontSize: 13, color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _edukasiTerbaru.length,
                      itemBuilder: (context, index) {
                        return _buildEdukasiCard(context, _edukasiTerbaru[index]);
                      },
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, ImageProvider? customAvatar, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      shadowColor: Colors.black.withOpacity(0.3),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6.0, 10.0, 6.0, 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              customAvatar != null
                  ? CircleAvatar(radius: 16, backgroundImage: customAvatar)
                  : Icon(icon, color: AppColors.primaryGreen, size: 32), 
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textCharcoal)),
              const SizedBox(height: 4),
              Expanded(
                child: Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: AppColors.textLight, height: 1.2)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEdukasiCard(BuildContext context, Map<String, String> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EdukasiScreen())),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    data['image']!,
                    height: 75,
                    width: 75,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        data['url']!,
                        height: 75,
                        width: 75,
                        fit: BoxFit.cover,
                        errorBuilder: (context, err, stack) => Container(
                          height: 75, width: 75, color: Colors.green.shade50,
                          child: const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 30),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['title']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textCharcoal), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Text(data['subtitle']!, style: const TextStyle(fontSize: 11, color: AppColors.textLight), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Text(data['date']!, style: const TextStyle(fontSize: 10, color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}