import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/colors.dart';
import '../../data/helpers/database_helper.dart'; 
import '../../data/helpers/shared_prefs_helper.dart'; 

class ArticleDetailScreen extends StatefulWidget {
  final Map<String, String> data;

  const ArticleDetailScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  // SINKRONISASI CEK DATA (SQLITE & WEB)
  Future<void> _checkIfSaved() async {
    try {
      if (kIsWeb) {
        // Jalur Web Browser fallback via SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final String? webSavedJson = prefs.getString('web_saved_articles');
        if (webSavedJson != null) {
          final List<dynamic> decoded = jsonDecode(webSavedJson);
          if (mounted) {
            setState(() {
              _isSaved = decoded.any((item) => item['title'] == widget.data['title']);
            });
          }
        }
      } else {
        // Jalur Rill Emulator Android menggunakan fungsi SQLite bawaan kelompokmu
        final List<Map<String, dynamic>> savedArticles = await DatabaseHelper.instance.getSavedArticles();
        if (mounted) {
          setState(() {
            _isSaved = savedArticles.any((item) => item['title'] == widget.data['title']);
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal memeriksa status simpan artikel: $e");
    }
  }

  // SINKRONISASI TOGGLE CRUD (CREATE & DELETE)
  Future<void> _toggleSaveArticle() async {
    final Map<String, dynamic> articleData = {
      'title': widget.data['title'] ?? '',
      'subtitle': widget.data['subtitle'] ?? '', 
      'date': widget.data['date'] ?? '',
      'image': widget.data['image'] ?? '', 
      'content': widget.data['content'] ?? '',
    };

    try {
      if (kIsWeb) {
        // === JALUR UNTUK WEB CHROME ===
        final prefs = await SharedPreferences.getInstance();
        final String? webSavedJson = prefs.getString('web_saved_articles');
        List<dynamic> savedList = webSavedJson != null ? jsonDecode(webSavedJson) : [];

        if (_isSaved) {
          savedList.removeWhere((item) => item['title'] == widget.data['title']);
          await prefs.setString('web_saved_articles', jsonEncode(savedList));
          await SharedPrefsHelper.saveActivity('User menghapus bookmark artikel: ${widget.data['title']}');
          setState(() => _isSaved = false);
          _showCompactTopToast('Artikel dihapus dari simpanan', isError: true);
        } else {
          savedList.add(articleData);
          await prefs.setString('web_saved_articles', jsonEncode(savedList));
          await SharedPrefsHelper.saveActivity('User menyimpan artikel baru: ${widget.data['title']}');
          setState(() => _isSaved = true);
          _showCompactTopToast('Artikel disimpan ke profil!');
        }
      } else {
        // === JALUR RILL UNTUK EMULATOR ANDROID SQLITE ===
        if (_isSaved) {
          // Operasi DELETE SQLite rill berdasarkan JUDUL (Mencegah eror int!)
          await DatabaseHelper.instance.deleteArticle(widget.data['title']!);
          await SharedPrefsHelper.saveActivity('User menghapus artikel dari database: ${widget.data['title']}');
          setState(() => _isSaved = false);
          _showCompactTopToast('Artikel dihapus dari simpanan', isError: true);
        } else {
          // Operasi CREATE/INSERT SQLite rill
          await DatabaseHelper.instance.insertArticle(articleData);
          await SharedPrefsHelper.saveActivity('User menambahkan artikel baru ke database: ${widget.data['title']}');
          setState(() => _isSaved = true);
          _showCompactTopToast('Artikel disimpan ke profil!');
        }
      }
    } catch (e) {
      debugPrint("Gagal mengubah status simpan artikel: $e");
    }
  }

  // PIL TOAST NOTIFIKASI MINI CAPSULE (100% MODEREN & AESTHETIC)
  void _showCompactTopToast(String message, {bool isError = false}) {
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
                color: isError ? const Color(0xFFFFF2F2) : const Color(0xFFF2FDF5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isError ? Colors.red.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.2), 
                  width: 1
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 6)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isError ? Icons.error_rounded : Icons.check_circle_rounded,
                    color: isError ? Colors.redAccent : AppColors.primaryGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    message,
                    style: TextStyle(
                      color: isError ? Colors.red.shade900 : const Color(0xFF1B5E20),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(milliseconds: 2200), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textCharcoal),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: AppColors.primaryGreen,
              size: 26,
            ),
            onPressed: _toggleSaveArticle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.data['image'] ?? '',
              height: 230,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                height: 230, 
                color: const Color(0xFFF2FDF5),
                child: const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data['date'] ?? '',
                    style: const TextStyle(color: AppColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.data['title'] ?? '',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textCharcoal, height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.data['subtitle'] ?? '',
                    style: const TextStyle(fontSize: 14, color: AppColors.textLight, fontStyle: FontStyle.italic, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.cardLightGrey),
                  const SizedBox(height: 16),
                  Text(
                    widget.data['content'] ?? '',
                    style: const TextStyle(fontSize: 15, color: AppColors.textCharcoal, height: 1.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}