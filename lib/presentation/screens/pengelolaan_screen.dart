import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../data/helpers/database_helper.dart';
import 'article_detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data seed statis — ditampilkan setelah data Admin dari SQLite
// ─────────────────────────────────────────────────────────────────────────────
const List<Map<String, String>> _kStaticPengelolaan = [
  {
    'category': 'Olahan Dasar',
    'title'   : 'Cara Membuat Tepung Sorgum Bebas Gluten',
    'subtitle': 'Langkah mudah mengolah biji sorgum menjadi tepung serbaguna untuk aneka kue.',
    'image'   : 'https://images.unsplash.com/photo-1509486899865-09d56910b372?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
    'content' : 'Tepung sorgum adalah alternatif bebas gluten yang sangat baik untuk penderita seliak atau yang sedang diet.\n\nCara membuatnya:\n1. Cuci bersih biji sorgum dan rendam selama 12-24 jam.\n2. Tiriskan dan jemur hingga kering.\n3. Giling menggunakan mesin penepung atau blender.\n4. Ayak hasil gilingan untuk mendapatkan tekstur halus.\n5. Simpan dalam wadah kedap udara.',
  },
  {
    'category': 'Resep Kue',
    'title'   : 'Resep Brownies Lumer dari Tepung Sorgum',
    'subtitle': 'Membuat brownies cokelat lezat, sehat, dan 100% bebas gluten.',
    'image'   : 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
    'content' : 'Bahan-bahan:\n- 150g Tepung Sorgum\n- 200g Dark Chocolate\n- 100g Mentega\n- 3 Butir Telur\n- 120g Gula Palem\n\nCara Membuat:\n1. Kocok telur dan gula palem hingga larut.\n2. Masukkan cokelat dan mentega yang sudah dilelehkan.\n3. Masukkan tepung sorgum secara perlahan.\n4. Panggang pada suhu 170°C selama 30-35 menit.',
  },
  {
    'category': 'Makanan Pokok',
    'title'   : 'Menanak Nasi Sorgum yang Pulen dan Enak',
    'subtitle': 'Alternatif pengganti beras putih yang kaya akan serat dan rendah indeks glikemik.',
    'image'   : 'https://images.unsplash.com/photo-1512058564366-18510be2db19?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
    'content' : 'Langkah-langkah:\n1. Cuci beras sorgum 2-3 kali hingga airnya jernih.\n2. Rendam minimal 2 jam agar lebih cepat empuk.\n3. Masak dengan perbandingan air 1:3.\n4. Bisa dicampur beras putih (rasio 1:1) jika baru pertama kali mencoba.',
  },
];

// ─────────────────────────────────────────────────────────────────────────────
// PengelolaanScreen — membaca dari table_pengelolaan (Admin) + data seed statis
// ─────────────────────────────────────────────────────────────────────────────
class PengelolaanScreen extends StatefulWidget {
  const PengelolaanScreen({Key? key}) : super(key: key);

  @override
  State<PengelolaanScreen> createState() => _PengelolaanScreenState();
}

class _PengelolaanScreenState extends State<PengelolaanScreen> {
  late Future<List<Map<String, dynamic>>> _futureAdminData;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _futureAdminData = DatabaseHelper.instance.queryAllPengelolaanAdmin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Tutorial Pengelolaan',
          style: TextStyle(
              color: AppColors.textCharcoal,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textCharcoal),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureAdminData,
        builder: (context, snap) {
          final adminItems = snap.data ?? [];

          return RefreshIndicator(
            onRefresh: () async => _load(),
            color: AppColors.primaryGreen,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.all(24),
              itemCount: adminItems.length + _kStaticPengelolaan.length,
              itemBuilder: (context, index) {
                if (index < adminItems.length) {
                  // ── Kartu dari database Admin ──────────────────────────
                  return _AdminPengelolaanCard(data: adminItems[index]);
                } else {
                  // ── Kartu data seed statis ─────────────────────────────
                  final data = _kStaticPengelolaan[index - adminItems.length];
                  return _StaticTutorialCard(data: data);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget: Kartu panduan dari Admin (data SQLite)
// ─────────────────────────────────────────────────────────────────────────────
class _AdminPengelolaanCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _AdminPengelolaanCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final String thumbnail = data['thumbnail'] ?? '';
    final bool hasThumbnail = thumbnail.isNotEmpty;

    List<String> langkahList = [];
    try {
      final decoded = jsonDecode(data['langkah_solusi'] ?? '[]') as List;
      langkahList = decoded.map((e) => e.toString()).toList();
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _AdminPengelolaanDetailPage(
                data: data,
                langkahList: langkahList,
                hasThumbnail: hasThumbnail,
                thumbnailBase64: thumbnail,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Gambar / Thumbnail ─────────────────────────────────────
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  children: [
                    hasThumbnail
                        ? Image.memory(
                            base64Decode(thumbnail),
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 140,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF558B2F).withOpacity(0.8),
                                  const Color(0xFF2E7D32).withOpacity(0.6),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Icon(Icons.agriculture_rounded,
                                  size: 52, color: Colors.white54),
                            ),
                          ),
                    // Badge Kategori
                    Positioned(
                      top: 12, left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          data['kategori'] ?? '',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // Badge custom (dari field 'badge')
                    if ((data['badge'] ?? '').toString().isNotEmpty)
                      Positioned(
                        top: 12, right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            data['badge'],
                            style: const TextStyle(
                                color: Color(0xFF558B2F),
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // ── Teks ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['judul'] ?? '',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textCharcoal,
                          height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if ((data['masalah'] ?? data['konten'] ?? '').toString().isNotEmpty)
                      Text(
                        data['masalah'] ?? data['konten'] ?? '',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                            height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 16),
                    Row(children: [
                      const Text('Baca Tutorial',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded,
                          color: AppColors.primaryGreen, size: 16),
                      if ((data['estimasi_baca'] ?? '').toString().isNotEmpty) ...[
                        const Spacer(),
                        const Icon(Icons.schedule_rounded,
                            size: 12, color: AppColors.textLight),
                        const SizedBox(width: 3),
                        Text(data['estimasi_baca'],
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textLight)),
                      ],
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget: Kartu data seed statis (format lama, tidak berubah)
// ─────────────────────────────────────────────────────────────────────────────
class _StaticTutorialCard extends StatelessWidget {
  final Map<String, String> data;
  const _StaticTutorialCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> articleData = {
      'date'    : data['category']!,
      'title'   : data['title']!,
      'subtitle': data['subtitle']!,
      'image'   : data['image']!,
      'content' : data['content']!,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ArticleDetailScreen(data: articleData)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  children: [
                    Image.network(
                      data['image']!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        height: 180,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.fastfood_outlined,
                            size: 40, color: Colors.grey),
                      ),
                    ),
                    Positioned(
                      top: 12, left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          data['category']!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title']!,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textCharcoal,
                          height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['subtitle']!,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                          height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(children: [
                      const Text('Baca Tutorial',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded,
                          color: AppColors.primaryGreen, size: 16),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Halaman Detail panduan Admin
// ─────────────────────────────────────────────────────────────────────────────
class _AdminPengelolaanDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final List<String> langkahList;
  final bool hasThumbnail;
  final String thumbnailBase64;

  const _AdminPengelolaanDetailPage({
    required this.data,
    required this.langkahList,
    required this.hasThumbnail,
    required this.thumbnailBase64,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF558B2F);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: hasThumbnail ? 240 : 160,
            pinned: true,
            backgroundColor: accentColor,
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.black26,
                child: Icon(Icons.arrow_back, color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: hasThumbnail
                  ? Image.memory(base64Decode(thumbnailBase64),
                      fit: BoxFit.cover)
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF558B2F), Color(0xFF2E7D32)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.agriculture_rounded,
                            size: 64, color: Colors.white54),
                      ),
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori badge
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(data['kategori'] ?? '',
                          style: const TextStyle(
                              color: accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                    if ((data['estimasi_baca'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.schedule_rounded,
                          size: 13, color: AppColors.textLight),
                      const SizedBox(width: 3),
                      Text(data['estimasi_baca'],
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textLight)),
                    ],
                  ]),
                  const SizedBox(height: 12),
                  Text(data['judul'] ?? '',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textCharcoal,
                          height: 1.3)),
                  if ((data['judul_langkah'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(data['judul_langkah'],
                        style: const TextStyle(
                            fontSize: 13,
                            color: accentColor,
                            fontWeight: FontWeight.w600)),
                  ],
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  if ((data['masalah'] ?? '').toString().isNotEmpty)
                    _Section(
                        icon: Icons.report_problem_outlined,
                        color: const Color(0xFFE65100),
                        title: 'Masalah',
                        body: data['masalah']),

                  if ((data['penyebab'] ?? '').toString().isNotEmpty)
                    _Section(
                        icon: Icons.search_rounded,
                        color: const Color(0xFF1565C0),
                        title: 'Penyebab',
                        body: data['penyebab']),

                  if (langkahList.isNotEmpty) ...[
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.checklist_rounded,
                            color: accentColor, size: 16),
                      ),
                      const SizedBox(width: 8),
                      const Text('Langkah-langkah',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: accentColor)),
                    ]),
                    const SizedBox(height: 12),
                    ...langkahList.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28, height: 28,
                            decoration: const BoxDecoration(
                                color: accentColor, shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: Text('${e.key + 1}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(e.value,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textCharcoal,
                                    height: 1.5)),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 8),
                  ],

                  if ((data['tips_ahli'] ?? '').toString().isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8E9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accentColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_rounded,
                              color: accentColor, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tips Ahli',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: accentColor,
                                        fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(data['tips_ahli'],
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textCharcoal,
                                        height: 1.5)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _Section(
      {required this.icon,
      required this.color,
      required this.title,
      required this.body});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ]),
          const SizedBox(height: 10),
          Text(body,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textCharcoal, height: 1.6)),
        ]),
      );
}