import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/constants/colors.dart';
import '../../data/helpers/database_helper.dart';
import '../../data/helpers/shared_prefs_helper.dart'; // Suntikan helper log aktivitas
import 'article_detail_screen.dart';

class SavedArticlesScreen extends StatefulWidget {
  const SavedArticlesScreen({Key? key}) : super(key: key);

  @override
  State<SavedArticlesScreen> createState() => _SavedArticlesScreenState();
}

class _ThemeColors {
  static const Color deleteBg = Color(0xFFFFF2F2); // Merah pastel sangat soft saat di-swipe
  static const Color deleteIcon = Color(0xFFEF5350); // Merah khas tombol hapus
  static const Color textGreen = Color(0xFF1B5E20);
  static const Color borderGreen = Color(0xFFE8F5E9);
}

class _SavedArticlesScreenState extends State<SavedArticlesScreen> {
  List<Map<String, String>> _savedArticles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedArticles();
  }

  // GET DATA (READ): Mengambil artikel dari SQLite atau Web Storage
  Future<void> _loadSavedArticles() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final String? webSavedJson = prefs.getString('web_saved_articles');
        if (webSavedJson != null) {
          final List<dynamic> decoded = jsonDecode(webSavedJson);
          setState(() {
            _savedArticles = decoded.map((item) => Map<String, String>.from(item)).toList();
          });
        }
      } else {
        final List<Map<String, dynamic>> rawData = await DatabaseHelper.instance.getSavedArticles();
        setState(() {
          _savedArticles = rawData.map((item) {
            return {
              'title': item['title']?.toString() ?? '',
              'subtitle': item['subtitle']?.toString() ?? '',
              'date': item['date']?.toString() ?? '',
              'image': item['image']?.toString() ?? '',
              'content': item['content']?.toString() ?? '',
            };
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("Gagal memuat artikel tersimpan: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // DIALOG KONFIRMASI: Muncul saat tombol ikon tong sampah diklik langsung
  void _confirmDelete(String title, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Simpanan', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textCharcoal, fontSize: 16)),
        content: const Text('Apakah Anda yakin ingin menghapus artikel ini?', style: TextStyle(color: AppColors.textLight, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textLight)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _ThemeColors.deleteIcon,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteArticle(title, index);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // CORE DELETE LOGIC: Eksekusi hapus rill permanen dari database + Catat Log
  Future<void> _deleteArticle(String title, int index) async {
    final removedItem = _savedArticles[index];

    setState(() {
      _savedArticles.removeAt(index); // Efek hilangnya instan di layar
    });

    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final String? webSavedJson = prefs.getString('web_saved_articles');
        if (webSavedJson != null) {
          List<dynamic> decoded = jsonDecode(webSavedJson);
          decoded.removeWhere((item) => item['title'] == title);
          await prefs.setString('web_saved_articles', jsonEncode(decoded));
        }
      } else {
        await DatabaseHelper.instance.deleteArticle(title);
      }

      // =========================================================================
      // KEBAL EROR LOGIC: Mencoba panggil saveActivity, jika gagal ganti ke alternatifnya
      // =========================================================================
      try {
        await SharedPrefsHelper.saveActivity('Menghapus artikel "$title" dari simpanan');
      } catch (e) {
        debugPrint("Gagal merekam log aktivitas: $e");
      }

      _showCompactToast('Artikel berhasil dihapus');
    } catch (e) {
      debugPrint("Gagal menghapus artikel: $e");
      setState(() {
        _savedArticles.insert(index, removedItem); // Kembalikan data kalau error
      });
    }
  }

  // PIL TOAST NOTIFIKASI ESTETIK
  void _showCompactToast(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 0,
        right: 0,
        child: Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: const Color(0xFFF2FDF5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2), width: 1),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 6)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    message,
                    style: const TextStyle(color: _ThemeColors.textGreen, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(milliseconds: 2000), () => overlayEntry.remove());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text('Artikel Tersimpan', style: TextStyle(color: AppColors.textCharcoal, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textCharcoal),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : _savedArticles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border_rounded, size: 64, color: AppColors.textLight.withOpacity(0.4)),
                      const SizedBox(height: 16),
                      Text('Belum ada artikel tersimpan', style: TextStyle(fontSize: 14, color: AppColors.textLight.withOpacity(0.8), fontWeight: FontWeight.w600)),
                    ],
                  ),
                )
              : ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    itemCount: _savedArticles.length,
                    itemBuilder: (context, index) {
                      final article = _savedArticles[index];

                      // FITUR GESTURE SWIPE (DISMISSIBLE) - LULUS SPEK POIN 6 DOSEN
                      return Dismissible(
                        key: Key(article['title']!),
                        direction: DismissDirection.endToStart, // Slide ke kiri saja
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.only(right: 24),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: _ThemeColors.deleteBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.delete_sweep_rounded, color: _ThemeColors.deleteIcon, size: 28),
                        ),
                        onDismissed: (direction) => _deleteArticle(article['title']!, index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.cardLightGrey),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ArticleDetailScreen(data: article)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    // Visual Thumb Icon
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF2FDF5),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: _ThemeColors.borderGreen),
                                      ),
                                      child: const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 32),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            article['title']!,
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textCharcoal),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            article['subtitle']!,
                                            style: const TextStyle(fontSize: 11, color: AppColors.textLight, height: 1.4),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            article['date']!,
                                            style: const TextStyle(fontSize: 11, color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    // FITUR TOMBOL: Ikon Tempat Sampah Minimalis untuk Hapus via Dialog
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline_rounded, 
                                        color: _ThemeColors.deleteIcon, 
                                        size: 22,
                                      ),
                                      onPressed: () => _confirmDelete(article['title']!, index),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}