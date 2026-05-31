import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/colors.dart';

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

  // Memeriksa apakah artikel ini sudah pernah disimpan sebelumnya
  Future<void> _checkIfSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedList = prefs.getStringList('saved_articles') ?? [];
    
    setState(() {
      _isSaved = savedList.any((item) {
        final Map<String, dynamic> article = jsonDecode(item);
        return article['title'] == widget.data['title'];
      });
    });
  }

  // Fungsi Toggle Simpan/Hapus Artikel ke SharedPreferences secara permanen
  Future<void> _toggleSaveArticle() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedList = prefs.getStringList('saved_articles') ?? [];
    
    if (_isSaved) {
      // Hapus jika sudah tersimpan
      savedList.removeWhere((item) {
        final Map<String, dynamic> article = jsonDecode(item);
        return article['title'] == widget.data['title'];
      });
      await prefs.setStringList('saved_articles', savedList);
      setState(() => _isSaved = false);
      _showSnackBar('Artikel dihapus dari simpanan');
    } else {
      // Simpan objek data artikel dalam bentuk string JSON
      savedList.add(jsonEncode(widget.data));
      await prefs.setStringList('saved_articles', savedList);
      setState(() => _isSaved = true);
      _showSnackBar('Artikel berhasil disimpan ke profil!');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppColors.textCharcoal,
        duration: const Duration(seconds: 2),
      ),
    );
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
          // Tombol simpan ikon bookmark dinamis
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
              widget.data['image']!,
              height: 230,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                height: 230, 
                color: Colors.green.shade50,
                child: const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data['date']!,
                    style: const TextStyle(color: AppColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.data['title']!,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textCharcoal, height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.data['subtitle']!,
                    style: const TextStyle(fontSize: 14, color: AppColors.textLight, fontStyle: FontStyle.italic, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.cardLightGrey),
                  const SizedBox(height: 16),
                  Text(
                    widget.data['content']!,
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