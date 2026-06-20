import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../data/helpers/database_helper.dart';
import 'article_detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data seed bawaan — ditampilkan sebagai kartu statis di bagian bawah
// setelah data dari SQLite (yang dibuat Admin)
// ─────────────────────────────────────────────────────────────────────────────
const List<Map<String, String>> _kStaticEdukasi = [
  {
    'title'  : 'Budidaya Sorgum Varietas Bioguma 1 Agritan',
    'subtitle': 'Mengenal varietas unggul dengan potensi hasil mencapai 7 ton per hektar.',
    'date'   : '01 Juni 2026',
    'image'  : 'https://images.unsplash.com/photo-1592982537447-6f29cb91cb8e?ixlib=rb-1.2.1&auto=format&fit=crop&w=300&q=80',
    'content': 'Varietas Bioguma 1 Agritan dirilis resmi oleh Balitbangtan Kementan. Varietas ini memiliki keunggulan berupa tinggi tanaman sekitar 265 cm, toleran terhadap kekeringan, dan tahan terhadap hama karat daun (Puccinia purpurea). Selain bijinya yang produktif untuk pangan, batang Bioguma memiliki kadar kemanisan (nira) mencapai 11.5% brix, menjadikannya sangat ideal untuk produksi bioetanol maupun pakan ternak silase premium.',
  },
  {
    'title'  : 'Dosis Pemupukan NPK Spesifik Lokasi Lahan',
    'subtitle': 'Teknik pemberian hara makro Nitrogen, Fosfor, dan Kalium untuk tanaman sorgum.',
    'date'   : '28 Mei 2026',
    'image'  : 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?ixlib=rb-1.2.1&auto=format&fit=crop&w=300&q=80',
    'content': 'Untuk mencapai hasil malai yang optimal pada tanah marginal atau tadah hujan, rekomendasi pemupukan per hektar adalah 200 kg pupuk Urea, 100 kg SP-36, dan 50 kg KCl.',
  },
  {
    'title'  : 'Pengendalian Hama Lalat Bibit (Atherigona soccata)',
    'subtitle': 'Cara mendeteksi gejala dead-heart dan solusi penanganannya secara organik.',
    'date'   : '15 Mei 2026',
    'image'  : 'https://images.unsplash.com/photo-1530836369250-ef71a3f5e48d?ixlib=rb-1.2.1&auto=format&fit=crop&w=300&q=80',
    'content': 'Hama lalat bibit (Atherigona soccata) menyerang tanaman sorgum muda pada umur 1 hingga 3 minggu setelah tanam. Larva masuk ke dalam batang dan memakan titik tumbuh, menyebabkan pucuk daun layu dan kering (gejala dead-heart).',
  },
];

// ─────────────────────────────────────────────────────────────────────────────
// EdukasiScreen — membaca dari table_edukasi (Admin) + data seed statis
// ─────────────────────────────────────────────────────────────────────────────
class EdukasiScreen extends StatefulWidget {
  const EdukasiScreen({Key? key}) : super(key: key);

  @override
  State<EdukasiScreen> createState() => _EdukasiScreenState();
}

class _EdukasiScreenState extends State<EdukasiScreen> {
  late Future<List<Map<String, dynamic>>> _futureAdminData;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _futureAdminData = DatabaseHelper.instance.queryAllEdukasi();
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
            'Edukasi Sorgum',
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
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _futureAdminData,
            builder: (context, snap) {
              // Konversi data admin SQLite ke format kartu yang sama
              final adminItems = snap.data ?? [];

              return RefreshIndicator(
                onRefresh: () async => _load(),
                color: AppColors.primaryGreen,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  // Admin items dulu, lalu data seed statis
                  itemCount: adminItems.length + _kStaticEdukasi.length,
                  itemBuilder: (context, index) {
                    if (index < adminItems.length) {
                      // ── Kartu dari database Admin ────────────────────────
                      return _AdminArticleCard(data: adminItems[index]);
                    } else {
                      // ── Kartu data seed statis ────────────────────────────
                      final data = _kStaticEdukasi[index - adminItems.length];
                      return _StaticArticleCard(data: data);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget: Kartu artikel dari Admin (data SQLite, bisa punya thumbnail base64)
// ─────────────────────────────────────────────────────────────────────────────
class _AdminArticleCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _AdminArticleCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final String thumbnail = data['thumbnail'] ?? '';
    final bool hasThumbnail = thumbnail.isNotEmpty;

    // Langkah-langkah solusi dari JSON
    List<String> langkahList = [];
    try {
      final decoded = jsonDecode(data['langkah_solusi'] ?? '[]') as List;
      langkahList = decoded.map((e) => e.toString()).toList();
    } catch (_) {}

    // Bangun konten lengkap untuk ArticleDetailScreen
    final StringBuffer contentBuf = StringBuffer();
    if ((data['masalah'] ?? '').toString().isNotEmpty) {
      contentBuf.writeln('📋 Masalah:\n${data['masalah']}\n');
    }
    if ((data['penyebab'] ?? '').toString().isNotEmpty) {
      contentBuf.writeln('🔍 Penyebab:\n${data['penyebab']}\n');
    }
    if (langkahList.isNotEmpty) {
      contentBuf.writeln('✅ Langkah Solusi:');
      for (int i = 0; i < langkahList.length; i++) {
        contentBuf.writeln('${i + 1}. ${langkahList[i]}');
      }
      contentBuf.writeln('');
    }
    if ((data['tips_ahli'] ?? '').toString().isNotEmpty) {
      contentBuf.writeln('💡 Tips Ahli:\n${data['tips_ahli']}');
    }
    if (contentBuf.isEmpty) {
      contentBuf.write(data['konten'] ?? '');
    }

    final articleData = <String, String>{
      'title'   : data['judul']    ?? '',
      'subtitle': data['masalah']  ?? data['konten'] ?? '',
      'date'    : data['tanggal']  ?? '',
      'image'   : '',
      'content' : contentBuf.toString(),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardLightGrey, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
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
              builder: (_) => _AdminArticleDetailPage(
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
              // ── Thumbnail ──────────────────────────────────────────────
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: hasThumbnail
                    ? Image.memory(
                        base64Decode(thumbnail),
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryGreen.withOpacity(0.8),
                              const Color(0xFF2E7D32).withOpacity(0.6),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            const Center(
                              child: Icon(Icons.menu_book_rounded,
                                  size: 48, color: Colors.white54),
                            ),
                            // Badge Kategori
                            Positioned(
                              top: 10, right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  data['kategori'] ?? '',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              // ── Info teks ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge + Status tag row
                    if ((data['badge'] ?? '').toString().isNotEmpty ||
                        (data['estimasi_baca'] ?? '').toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(children: [
                          if ((data['badge'] ?? '').isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(data['badge'],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold)),
                            ),
                          if ((data['badge'] ?? '').isNotEmpty &&
                              (data['estimasi_baca'] ?? '').isNotEmpty)
                            const SizedBox(width: 6),
                          if ((data['estimasi_baca'] ?? '').isNotEmpty)
                            Row(children: [
                              const Icon(Icons.schedule_rounded,
                                  size: 11, color: AppColors.textLight),
                              const SizedBox(width: 3),
                              Text(data['estimasi_baca'],
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textLight)),
                            ]),
                        ]),
                      ),
                    Text(
                      data['judul'] ?? '',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textCharcoal),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if ((data['masalah'] ?? data['konten'] ?? '').toString().isNotEmpty)
                      Text(
                        data['masalah'] ?? data['konten'] ?? '',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                            height: 1.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 12, color: AppColors.primaryGreen),
                          const SizedBox(width: 6),
                          Text(
                            data['tanggal'] ?? '',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward_rounded,
                              color: AppColors.primaryGreen, size: 16),
                        ),
                      ],
                    ),
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
class _StaticArticleCard extends StatelessWidget {
  final Map<String, String> data;
  const _StaticArticleCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardLightGrey, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
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
                builder: (_) => ArticleDetailScreen(data: data)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  data['image']!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.green.shade50,
                    child: const Icon(Icons.eco_rounded,
                        color: AppColors.primaryGreen, size: 40),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title']!,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textCharcoal),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data['subtitle']!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textLight, height: 1.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 12, color: AppColors.primaryGreen),
                          const SizedBox(width: 6),
                          Text(
                            data['date']!,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward_rounded,
                              color: AppColors.primaryGreen, size: 16),
                        ),
                      ],
                    ),
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
// Halaman Detail artikel Admin (menampilkan langkah-langkah, tips, thumbnail)
// ─────────────────────────────────────────────────────────────────────────────
class _AdminArticleDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final List<String> langkahList;
  final bool hasThumbnail;
  final String thumbnailBase64;

  const _AdminArticleDetailPage({
    required this.data,
    required this.langkahList,
    required this.hasThumbnail,
    required this.thumbnailBase64,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero Thumbnail ───────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: hasThumbnail ? 240 : 160,
            pinned: true,
            backgroundColor: const Color(0xFF2E7D32),
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.black26,
                child: Icon(Icons.arrow_back, color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: hasThumbnail
                  ? Image.memory(base64Decode(thumbnailBase64), fit: BoxFit.cover)
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2E7D32), Color(0xFF65B713)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.menu_book_rounded,
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
                  // Judul & badge info
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        data['kategori'] ?? '',
                        style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
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
                  Text(
                    data['judul'] ?? '',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textCharcoal,
                        height: 1.3),
                  ),
                  if ((data['judul_langkah'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(data['judul_langkah'],
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600)),
                  ],
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Masalah
                  if ((data['masalah'] ?? '').toString().isNotEmpty)
                    _DetailSection(
                      icon: Icons.report_problem_outlined,
                      color: const Color(0xFFE65100),
                      title: 'Masalah',
                      body: data['masalah'],
                    ),

                  // Penyebab
                  if ((data['penyebab'] ?? '').toString().isNotEmpty)
                    _DetailSection(
                      icon: Icons.search_rounded,
                      color: const Color(0xFF1565C0),
                      title: 'Penyebab',
                      body: data['penyebab'],
                    ),

                  // Langkah Solusi
                  if (langkahList.isNotEmpty) ...[
                    _SectionTitle(
                        icon: Icons.checklist_rounded,
                        color: AppColors.primaryGreen,
                        title: 'Langkah Solusi'),
                    const SizedBox(height: 12),
                    ...langkahList.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28, height: 28,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                            ),
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

                  // Tips Ahli
                  if ((data['tips_ahli'] ?? '').toString().isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8E9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.primaryGreen.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_rounded,
                              color: AppColors.primaryGreen, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tips Ahli',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryGreen,
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

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  const _SectionTitle(
      {required this.icon, required this.color, required this.title});

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration:
              BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ]);
}

class _DetailSection extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _DetailSection(
      {required this.icon,
      required this.color,
      required this.title,
      required this.body});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _SectionTitle(icon: icon, color: color, title: title),
          const SizedBox(height: 10),
          Text(body,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textCharcoal, height: 1.6)),
        ]),
      );
}