import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class ArtikelScreen extends StatelessWidget {
  const ArtikelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artikel & Berita', style: TextStyle(color: AppColors.textCharcoal)), backgroundColor: Colors.white, iconTheme: const IconThemeData(color: AppColors.textCharcoal)),
      body: const Center(child: Text('Halaman Daftar Artikel Lengkap')),
    );
  }
}