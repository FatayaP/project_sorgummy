import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'article_detail_screen.dart';

class EdukasiScreen extends StatelessWidget {
  const EdukasiScreen({Key? key}) : super(key: key);

  // DATA RILL: Varietas Resmi Balitbangtan Kementan & Teknik Budidaya Nyata
  final List<Map<String, String>> _edukasiList = const [
    {
      'title': 'Budidaya Sorgum Varietas Bioguma 1 Agritan',
      'subtitle': 'Mengenal varietas unggul dengan potensi hasil mencapai 7 ton per hektar.',
      'date': '01 Juni 2026',
      'image': 'https://images.unsplash.com/photo-1592982537447-6f29cb91cb8e?ixlib=rb-1.2.1&auto=format&fit=crop&w=300&q=80',
      'content': 'Varietas Bioguma 1 Agritan dirilis resmi oleh Balitbangtan Kementan. Varietas ini memiliki keunggulan berupa tinggi tanaman sekitar 265 cm, toleran terhadap kekeringan, dan tahan terhadap hama karat daun (Puccinia purpurea). Selain bijinya yang produktif untuk pangan, batang Bioguma memiliki kadar kemanisan (nira) mencapai 11.5% brix, menjadikannya sangat ideal untuk produksi bioetanol maupun pakan ternak silase premium.',
    },
    {
      'title': 'Dosis Pemupukan NPK Spesifik Lokasi Lahan',
      'subtitle': 'Teknik pemberian hara makro Nitrogen, Fosfor, dan Kalium untuk tanaman sorgum.',
      'date': '28 Mei 2026',
      'image': 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?ixlib=rb-1.2.1&auto=format&fit=crop&w=300&q=80',
      'content': 'Untuk mencapai hasil malai yang optimal pada tanah marginal atau tadah hujan, rekomendasi pemupukan rill secara nasional per hektar adalah 200 kg pupuk Urea, 100 kg SP-36, dan 50 kg KCl. Pengaplikasian dibagi menjadi dua fase rill: Seluruh dosis SP-36 dan KCl beserta 1/3 bagian Urea diberikan sebagai pupuk dasar saat tanam (0 HST). Sisa 2/3 pupuk Urea diberikan sebagai pupuk susulan ketika tanaman memasuki fase vegetatif aktif di umur 21 sampai 30 HST.',
    },
    {
      'title': 'Pengendalian Hama Lalat Bibit (Atherigona soccata)',
      'subtitle': 'Cara mendeteksi gejala dead-heart dan solusi penanganannya secara organik.',
      'date': '15 Mei 2026',
      'image': 'https://images.unsplash.com/photo-1530836369250-ef71a3f5e48d?ixlib=rb-1.2.1&auto=format&fit=crop&w=300&q=80',
      'content': 'Hama lalat bibit (Atherigona soccata) menyerang tanaman sorgum muda pada umur 1 hingga 3 minggu setelah tanam. Larva masuk ke dalam batang dan memakan titik tumbuh, menyebabkan pucuk daun layu dan kering (gejala dead-heart). Pengendalian rill secara hayati dilakukan dengan perlakuan benih (seed treatment) menggunakan ekstrak tanaman mimba atau penyemprotan agens hayati Beauveria bassiana secara berkala pada sore hari sejak tanaman berdaun dua.',
    },
  ];

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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: double.infinity),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                itemCount: _edukasiList.length,
                itemBuilder: (context, index) {
                  final data = _edukasiList[index];
                  return _buildArticleCard(context, data);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, Map<String, String> data) {
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
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => ArticleDetailScreen(data: data)),
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
                    child: const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 40),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title']!, 
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textCharcoal), 
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data['subtitle']!, 
                      style: const TextStyle(fontSize: 12, color: AppColors.textLight, height: 1.5), 
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.primaryGreen),
                            const SizedBox(width: 6),
                            Text(
                              data['date']!, 
                              style: const TextStyle(fontSize: 11, color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryGreen, size: 16),
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