import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/colors.dart';
import 'article_detail_screen.dart';

class SavedArticlesScreen extends StatefulWidget {
  const SavedArticlesScreen({Key? key}) : super(key: key);

  @override
  State<SavedArticlesScreen> createState() => _SavedArticlesScreenState();
}

class _SavedArticlesScreenState extends State<SavedArticlesScreen> {
  List<Map<String, String>> _savedArticles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedArticles();
  }

  // Membaca list string JSON dari storage perangkat dan men-decode kembali ke Map
  Future<void> _loadSavedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedList = prefs.getStringList('saved_articles') ?? [];
    
    final List<Map<String, String>> loadedArticles = savedList.map((item) {
      final Map<String, dynamic> decoded = jsonDecode(item);
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    }).toList();

    setState(() {
      _savedArticles = loadedArticles;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: AppBar(
          title: const Text(
            'Artikel Tersimpan',
            style: TextStyle(color: AppColors.textCharcoal, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: const BackButton(color: AppColors.textCharcoal),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: AppColors.cardLightGrey, height: 1.0),
          ),
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
              : _savedArticles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.bookmark_border_rounded, size: 60, color: AppColors.textLight),
                          SizedBox(height: 12),
                          Text(
                            'Belum ada artikel yang disimpan',
                            style: TextStyle(color: AppColors.textLight, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      itemCount: _savedArticles.length,
                      itemBuilder: (context, index) {
                        final data = _savedArticles[index];
                        return _buildSavedCard(context, data);
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildSavedCard(BuildContext context, Map<String, String> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardLightGrey, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            // Ketika user klik kartu, pergi ke detail, dan refresh list saat kembali (jika unbookmark)
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ArticleDetailScreen(data: data)),
            );
            _loadSavedArticles();
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    data['image']!,
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      height: 70, 
                      width: 70, 
                      color: Colors.green.shade50,
                      child: const Icon(Icons.eco_rounded, color: AppColors.primaryGreen),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title']!,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textCharcoal),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['subtitle']!,
                        style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data['date']!,
                        style: const TextStyle(fontSize: 10, color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
              ],
            ),
          ),
        ),
      ),
    );
  }
}