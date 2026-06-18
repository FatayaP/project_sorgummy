import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'article_detail_screen.dart';

class PengelolaanScreen extends StatelessWidget {
  const PengelolaanScreen({super.key});

  // Data list artikel difokuskan pada pengolahan/resep turunan sorgum
  final List<Map<String, String>> _pengelolaanList = const [
    {
      'category': 'Olahan Dasar',
      'title': 'Cara Membuat Tepung Sorgum Bebas Gluten',
      'subtitle': 'Langkah mudah mengolah biji sorgum menjadi tepung serbaguna untuk aneka kue.',
      'image': 'https://images.unsplash.com/photo-1509486899865-09d56910b372?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80', 
      'content': 'Tepung sorgum adalah alternatif bebas gluten yang sangat baik untuk penderita seliak atau yang sedang diet.\n\nCara membuatnya:\n1. Cuci bersih biji sorgum dan rendam selama 12-24 jam untuk menghilangkan zat tanin berlebih.\n2. Tiriskan dan jemur biji sorgum di bawah sinar matahari hingga benar-benar kering.\n3. Giling biji sorgum menggunakan mesin penepung (miller) atau blender bertenaga tinggi.\n4. Ayak hasil gilingan untuk mendapatkan tekstur tepung yang sangat halus.\n5. Simpan tepung dalam wadah kedap udara agar tahan lama.',
    },
    {
      'category': 'Resep Kue',
      'title': 'Resep Brownies Lumer dari Tepung Sorgum',
      'subtitle': 'Membuat brownies cokelat lezat, sehat, dan 100% bebas gluten.',
      'image': 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80', 
      'content': 'Siapa bilang kue sehat tidak bisa enak? Brownies dari tepung sorgum ini memiliki tekstur fudgy dan rasa cokelat yang pekat.\n\nBahan-bahan:\n- 150g Tepung Sorgum\n- 200g Dark Chocolate (lelehkan)\n- 100g Mentega\n- 3 Butir Telur\n- 120g Gula Palem\n- 1/2 sdt Baking Powder\n\nCara Membuat:\n1. Kocok telur dan gula palem hingga larut.\n2. Masukkan cokelat dan mentega yang sudah dilelehkan, aduk rata.\n3. Masukkan tepung sorgum dan baking powder secara perlahan.\n4. Tuang ke dalam loyang yang sudah dialasi kertas roti.\n5. Panggang pada suhu 170°C selama 30-35 menit. Sajikan selagi hangat!',
    },
    {
      'category': 'Makanan Pokok',
      'title': 'Menanak Nasi Sorgum yang Pulen dan Enak',
      'subtitle': 'Alternatif pengganti beras putih yang kaya akan serat dan rendah indeks glikemik.',
      'image': 'https://images.unsplash.com/photo-1512058564366-18510be2db19?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
      'content': 'Nasi sorgum (atau beras sorgum) sangat cocok bagi penderita diabetes karena rendah gula. Agar teksturnya tidak keras, perhatikan cara masaknya.\n\nLangkah-langkah:\n1. Cuci beras sorgum sebanyak 2-3 kali hingga airnya jernih.\n2. Rendam beras sorgum minimal 2 jam (atau semalaman) agar lebih cepat empuk saat dimasak.\n3. Masukkan ke dalam rice cooker dengan perbandingan air 1:3 (1 gelas sorgum, 3 gelas air).\n4. Anda juga bisa mencampurnya dengan beras putih biasa (rasio 1:1) jika baru pertama kali mencoba.\n5. Masak hingga matang dan biarkan di dalam rice cooker selama 15 menit sebelum diaduk.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text('Tutorial Pengelolaan', style: TextStyle(color: AppColors.textCharcoal, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textCharcoal),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24.0),
        itemCount: _pengelolaanList.length,
        itemBuilder: (context, index) {
          final data = _pengelolaanList[index];
          return _buildTutorialCard(context, data);
        },
      ),
    );
  }

  Widget _buildTutorialCard(BuildContext context, Map<String, String> data) {
    // Agar kompatibel dengan ArticleDetailScreen yang memakai 'date' di desain sebelumnya,
    // kita oper 'category' ke dalam 'date' agar posisinya pas di UI ArticleDetail.
    final Map<String, String> articleData = {
      'date': data['category']!,
      'title': data['title']!,
      'subtitle': data['subtitle']!,
      'image': data['image']!,
      'content': data['content']!,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Bayangan super halus tanpa border kotak
            blurRadius: 15, 
            offset: const Offset(0, 5)
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Membuka halaman baca artikel penuh
            Navigator.push(context, MaterialPageRoute(builder: (_) => ArticleDetailScreen(data: articleData)));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar besar di bagian atas kartu untuk daya tarik visual makanan/produk
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  children: [
                    Image.network(
                      data['image']!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(height: 180, color: Colors.grey.shade200, child: const Icon(Icons.fastfood_outlined, size: 40, color: Colors.grey)),
                    ),
                    // Label Kategori (misal: "Resep Kue")
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          data['category']!,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Bagian teks artikel
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title']!, 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textCharcoal, height: 1.3), 
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['subtitle']!, 
                      style: const TextStyle(fontSize: 12, color: AppColors.textLight, height: 1.4), 
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Baca Tutorial', style: TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, color: AppColors.primaryGreen, size: 16),
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