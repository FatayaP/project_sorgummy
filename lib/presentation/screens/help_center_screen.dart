import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false), // Sembunyikan scrollbar web kaku
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: AppBar(
          title: const Text(
            'Pusat Bantuan', 
            style: TextStyle(color: AppColors.textCharcoal, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white, 
          centerTitle: true,
          leading: const BackButton(color: AppColors.textCharcoal),
          elevation: 0,
          // Garis pembatas bawah tipis agar seragam dengan modul pengaturan lainnya
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: AppColors.cardLightGrey, height: 1.0),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: double.infinity), // Lebar penuh responsif
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                children: [
                  const Text(
                    'Pertanyaan Sering Diajukan (FAQ)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textCharcoal),
                  ),
                  const SizedBox(height: 16),
                  
                  // Item Bantuan 1
                  _buildHelpCard(
                    title: 'Bagaimana cara menggunakan Chat AI?',
                    content: 'Anda dapat langsung masuk ke menu "Chat AI" dari halaman beranda. Ketik pertanyaan seputar budidaya sorgum atau kendala lahan Anda, maka AI akan memberikan panduan cepat secara real-time.',
                  ),
                  const SizedBox(height: 12),

                  // Item Bantuan 2
                  _buildHelpCard(
                    title: 'Cara mencatat pengelolaan lahan?',
                    content: 'Buka menu "Pengelolaan" pada navigasi utama, lalu klik tombol tambah (+) yang ada di bagian layar untuk membuat log catatan pemupukan, jadwal siram, atau pemantauan hama baru.',
                  ),
                  const SizedBox(height: 12),

                  // Item Bantuan 3
                  _buildHelpCard(
                    title: 'Hubungi Hubungan Pengguna / CS',
                    content: 'Jika Anda menemukan kendala teknis atau memiliki pertanyaan kerja sama lebih lanjut seputar platform Sorgummi AI, jangan ragu untuk mengirimkan email kepada kami via support@sorgummi.com.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Komponen pembangun ExpansionTile berbentuk kartu melengkung yang bersih
  Widget _buildHelpCard({required String title, required String content}) {
    return Theme(
      // Menghilangkan garis pembatas default atas-bawah milik ExpansionTile bawaan Flutter
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardLightGrey, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ExpansionTile(
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textCharcoal),
          ),
          iconColor: AppColors.primaryGreen,
          collapsedIconColor: AppColors.textLight,
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: AppColors.cardLightGrey, height: 1),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}