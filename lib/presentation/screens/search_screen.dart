import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'edukasi_screen.dart'; 

class SearchScreen extends StatefulWidget {
  final String query;
  const SearchScreen({Key? key, required this.query}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  List<Map<String, String>> _searchResults = [];

  // ==========================================
  // DATA NYA (Silakan sinkronisasikan/ganti dengan model data asli atau API Anda di sini)
  // ==========================================
  final List<Map<String, String>> _sorgumDataList = const [
    {
      'title': 'Panduan Pemupukan Sorgum yang Tepat',
      'subtitle': 'Tingkatkan hasil panen dengan teknik pemupukan ini.',
      'date': '31 Mei 2026',
      'image': 'assets/images/pemupukan.png',
      'category': 'Edukasi Budidaya',
    },
    {
      'title': 'Cara Mengatasi Penyakit Daun Menguning',
      'subtitle': 'Kenali penyebab dan solusi cepat mengatasinya.',
      'date': '28 Mei 2026',
      'image': 'assets/images/daun_kuning.png',
      'category': 'Hama & Penyakit',
    },
    {
      'title': 'Persiapan Lahan Ideal untuk Benih',
      'subtitle': 'Langkah awal untuk pertumbuhan tanaman yang sehat.',
      'date': '25 Mei 2026',
      'image': 'assets/images/persiapan_lahan.png',
      'category': 'Persiapan Lahan',
    },
    {
      'title': 'Teknik Pengairan Efisien Lahan Kering',
      'subtitle': 'Cara mengatur air tanaman sorgum di musim kemarau.',
      'date': '20 Mei 2026',
      'image': 'assets/images/banner_bg.png',
      'category': 'Pengelolaan Air',
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
    _filterSearchData(widget.query); // Eksekusi pencarian pertama dari halaman home
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // LOGIKA FILTER DATA ASLI (Real-time Filtering)
  void _filterSearchData(String queryKey) {
    setState(() {
      if (queryKey.trim().isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _sorgumDataList.where((item) {
          final title = item['title']!.toLowerCase();
          final subtitle = item['subtitle']!.toLowerCase();
          final category = item['category']!.toLowerCase();
          final target = queryKey.toLowerCase();
          
          return title.contains(target) || subtitle.contains(target) || category.contains(target);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: AppColors.textCharcoal),
          title: Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.cardLightGrey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: (value) => _filterSearchData(value), // Live search pas user ngetik ulang
              style: const TextStyle(fontSize: 14, color: AppColors.textCharcoal),
              decoration: InputDecoration(
                hintText: 'Cari edukasi, pengelolaan...',
                hintStyle: TextStyle(color: AppColors.textLight.withOpacity(0.6), fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: AppColors.textLight, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textLight, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _filterSearchData('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: double.infinity),
              child: _searchResults.isEmpty 
                  ? _buildEmptyState() 
                  : _buildSearchResultsList(),
            ),
          ),
        ),
      ),
    );
  }

  // Tampilan Animasi Interaktif saat data tidak ditemukan
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search_off_rounded, 
                    size: 64, 
                    color: AppColors.primaryGreen,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Tidak Ditemukan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textCharcoal),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Kata kunci "${_searchController.text}" tidak cocok dengan data artikel Sorgummi manapun.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textLight, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // List Item Pencarian
  Widget _buildSearchResultsList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final data = _searchResults[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
            ],
            border: Border.all(color: AppColors.dividerGrey.withOpacity(0.4)),
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
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 75, width: 75, color: Colors.green.shade50,
                          child: const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              data['category']!,
                              style: const TextStyle(fontSize: 9, color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(data['title']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textCharcoal), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(data['subtitle']!, style: const TextStyle(fontSize: 11, color: AppColors.textLight), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}