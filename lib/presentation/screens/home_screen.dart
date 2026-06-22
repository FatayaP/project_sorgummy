import 'dart:convert'; // Untuk decode base64 gambar
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/colors.dart';
import '../../data/helpers/database_helper.dart';
import '../../data/helpers/shared_prefs_helper.dart';
import 'chat_screen.dart';
import 'pengelolaan_screen.dart';
import 'notification_screen.dart';
import 'search_screen.dart';
import 'edukasi_screen.dart';
import 'artikel_screen.dart';
import 'profile_screen.dart';
import 'daily_notes_screen.dart';
import '../widgets/history_tag_cloud.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _homeBase64Image; // Sinkronisasi gambar via SharedPreferences
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchHistory = [];
  bool _isSearchSuggestionsOn = true;
  bool _isSearchFocused = false;
  bool _isInteractingWithHistory = false;

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
    _loadSearchHistorySettings();
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        setState(() {
          _isSearchFocused = true;
        });
        _loadSearchHistory();
      } else {
        if (_isInteractingWithHistory) return;
        // Beri jeda agar tap pada item riwayat sempat terproses sebelum widget ditutup
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && !_searchFocusNode.hasFocus && !_isInteractingWithHistory) {
            setState(() {
              _isSearchFocused = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Memuat pengaturan status saran pencarian dari SharedPreferences
  Future<void> _loadSearchHistorySettings() async {
    final suggestionsOn = await SharedPrefsHelper.isSearchSuggestionsOn();
    setState(() {
      _isSearchSuggestionsOn = suggestionsOn;
    });
  }

  // Mengambil daftar riwayat pencarian terbaru dari database
  Future<void> _loadSearchHistory() async {
    final history = await DatabaseHelper.instance.getSearchHistory();
    setState(() {
      _searchHistory = history;
    });
  }

  // Eksekusi pencarian: menyimpan ke riwayat database lalu navigasi
  void _executeSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    await DatabaseHelper.instance.insertSearchHistory(trimmed);
    
    _searchController.clear();
    _searchFocusNode.unfocus();

    if (mounted) {
      _loadSearchHistory();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SearchScreen(query: trimmed)),
      ).then((_) {
        // Refresh data ketika kembali ke Beranda
        _loadSearchHistorySettings();
        _loadSearchHistory();
      });
    }
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
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (_searchFocusNode.hasFocus) {
                _searchFocusNode.unfocus();
              }
            },
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
                    // TextField Pencarian dengan penanganan focus dan aksi pencarian
                    GestureDetector(
                      onTap: () {}, // Mencegah klik di dalam kolom memicu GestureDetector luar
                      child: Container(
                        decoration: BoxDecoration(color: AppColors.cardLightGrey, borderRadius: BorderRadius.circular(50)),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          textInputAction: TextInputAction.search,
                          onSubmitted: _executeSearch,
                          style: const TextStyle(fontSize: 14, color: AppColors.textCharcoal),
                          decoration: InputDecoration(
                            hintText: 'Cari edukasi, pengelolaan, dll...',
                            hintStyle: TextStyle(color: AppColors.textLight.withOpacity(0.7), fontSize: 13),
                            prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                            suffixIcon: _isSearchFocused
                                ? IconButton(
                                    icon: const Icon(Icons.close, color: AppColors.textLight, size: 20),
                                    onPressed: () {
                                      _searchController.clear();
                                      _searchFocusNode.unfocus();
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),

                    // Tampilan List Riwayat Pencarian (Dropdown) jika aktif, difokuskan dan memiliki riwayat
                    if (_isSearchFocused && _isSearchSuggestionsOn && _searchHistory.isNotEmpty)
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 200),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, (1 - value) * -10),
                              child: child,
                            ),
                          );
                        },
                        child: Listener(
                          onPointerDown: (_) {
                            _isInteractingWithHistory = true;
                          },
                          onPointerUp: (_) {
                            _isInteractingWithHistory = false;
                            if (!_searchFocusNode.hasFocus) {
                              Future.delayed(const Duration(milliseconds: 200), () {
                                if (mounted && !_searchFocusNode.hasFocus && !_isInteractingWithHistory) {
                                  setState(() {
                                    _isSearchFocused = false;
                                  });
                                }
                              });
                            }
                          },
                          onPointerCancel: (_) {
                            _isInteractingWithHistory = false;
                            if (!_searchFocusNode.hasFocus) {
                              Future.delayed(const Duration(milliseconds: 200), () {
                                if (mounted && !_searchFocusNode.hasFocus && !_isInteractingWithHistory) {
                                  setState(() {
                                    _isSearchFocused = false;
                                  });
                                }
                              });
                            }
                          },
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {}, // Mencegah klik di area dropdown memicu penutupan focus secara otomatis
                            child: Container(
                              margin: const EdgeInsets.only(top: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                                border: Border.all(color: AppColors.dividerGrey.withOpacity(0.4)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Pencarian Terakhir',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textCharcoal,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          await DatabaseHelper.instance.clearAllSearchHistory();
                                          _loadSearchHistory();
                                        },
                                        child: const Text(
                                          'Hapus Semua',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(height: 1, color: AppColors.dividerGrey),
                                  const SizedBox(height: 8),
                                  InteractiveHistoryCanvasTagCloud(
                                    keywords: _searchHistory,
                                    onTagTapped: (keyword) {
                                      _executeSearch(keyword);
                                    },
                                    onTagDoubleTapped: (keyword) {
                                      _executeSearch(keyword);
                                    },
                                    onTagLongPressed: (keyword) async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                          title: const Text('Hapus Riwayat', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textCharcoal)),
                                          content: Text('Hapus "$keyword" dari riwayat pencarian Anda?', style: const TextStyle(color: AppColors.textLight)),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Batal', style: TextStyle(color: AppColors.textLight)),
                                            ),
                                            FilledButton(
                                              style: FilledButton.styleFrom(
                                                backgroundColor: Colors.redAccent,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Hapus'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true) {
                                        await DatabaseHelper.instance.deleteSearchHistoryItem(keyword);
                                        _loadSearchHistory();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
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
                        _buildMenuItem(context, null, Icons.note_alt_rounded, 'Catatan Harian', 'Tulis & kelola\ncatatan Anda', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyNotesScreen()))),
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