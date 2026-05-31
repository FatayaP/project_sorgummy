import 'dart:convert'; // Untuk encode & decode base64
import 'dart:io';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; // Pastikan package ini ada
import '../../core/constants/colors.dart';
import '../../data/helpers/shared_prefs_helper.dart';
import 'welcome_screen.dart';

import 'edit_profile_screen.dart';
import 'saved_articles_screen.dart';
import 'notification_settings_screen.dart';
import 'security_screen.dart';
import 'help_center_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _base64Image; // Menyimpan string base64 gambar agar permanen

  String _userName = 'Petani Hebat';
  String _userEmail = 'petani@sorgummi.com';
  String _userPhone = '081234567890';
  String _userAddress = 'Bandung, Jawa Barat';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Memuat foto profil yang tersimpan secara permanen
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _base64Image = prefs.getString('user_profile_image');
    });
  }

  // Fungsi Ambil Foto & Langsung Simpan Permanen ke Storage
  Future<void> _pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      final bytes = await selectedImage.readAsBytes();
      final base64String = base64Encode(bytes);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile_image', base64String);

      setState(() {
        _base64Image = base64String;
      });
      
      _showSnackBar('Foto profil berhasil diperbarui!');
    }
  }

  Future<void> _navigateToEditProfile() async {
    final Map<String, String>? newData = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          currentName: _userName,
          currentEmail: _userEmail,
          currentPhone: _userPhone,
          currentAddress: _userAddress,
        ),
      ),
    );

    if (newData != null) {
      setState(() {
        _userName = newData['name']!;
        _userEmail = newData['email']!;
        _userPhone = newData['phone']!;
        _userAddress = newData['address']!;
      });
      _showSnackBar('Perubahan profil berhasil diperbarui!');
    }
  }

  void _doLogout(BuildContext context) async {
    await SharedPrefsHelper.setLoggedIn(false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_profile_image'); // Hapus foto saat logout
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()), (route) => false);
    }
  }

  void _showSnackBar(String message) {
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

  ImageProvider _buildAvatarImage() {
    if (_base64Image != null && _base64Image!.isNotEmpty) {
      return MemoryImage(base64Decode(_base64Image!));
    }
    return const NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true); // Beri sinyal true ke Home kalau ada perubahan
        return false;
      },
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Scaffold(
          backgroundColor: AppColors.backgroundWhite,
          appBar: AppBar(
            title: const Text('Profil Saya', style: TextStyle(color: AppColors.textCharcoal, fontSize: 18, fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.backgroundWhite,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textCharcoal),
              onPressed: () => Navigator.pop(context, true),
            ),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3), width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.cardLightGrey,
                                backgroundImage: _buildAvatarImage(),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(_userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textCharcoal)),
                      const SizedBox(height: 4),
                      Text(_userEmail, style: const TextStyle(fontSize: 14, color: AppColors.textLight)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                          foregroundColor: AppColors.primaryGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        ),
                        onPressed: _navigateToEditProfile, 
                        child: const Text('Edit Profil', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildMenuSection(
                  context: context,
                  title: 'Pengaturan Akun',
                  items: [
                    _MenuData(icon: Icons.bookmark_border, title: 'Artikel Tersimpan', destination: const SavedArticlesScreen()),
                    _MenuData(icon: Icons.notifications_none, title: 'Notifikasi', destination: const NotificationSettingsScreen()),
                    _MenuData(icon: Icons.lock_outline, title: 'Keamanan & Password', destination: const SecurityScreen()),
                  ],
                ),
                const SizedBox(height: 24),
                _buildMenuSection(
                  context: context,
                  title: 'Lainnya',
                  items: [
                    _MenuData(icon: Icons.help_outline, title: 'Pusat Bantuan', destination: const HelpCenterScreen()),
                    _MenuData(icon: Icons.info_outline, title: 'Tentang Sorgummi AI', destination: const AboutScreen()),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => _showLogOutDialog(context),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text('Keluar Akun', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection({required BuildContext context, required String title, required List<_MenuData> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textCharcoal)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              int index = entry.key;
              _MenuData data = entry.value;
              bool isLast = index == items.length - 1;

              return Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: _getBorderRadius(index, items.length),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => data.destination)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          children: [
                            Icon(data.icon, color: AppColors.textLight, size: 24),
                            const SizedBox(width: 16),
                            Expanded(child: Text(data.title, style: const TextStyle(fontSize: 14, color: AppColors.textCharcoal, fontWeight: FontWeight.w500))),
                            const Icon(Icons.chevron_right, color: AppColors.dividerGrey, size: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!isLast) Divider(height: 1, color: AppColors.dividerGrey.withOpacity(0.5), indent: 60, endIndent: 20),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  BorderRadius _getBorderRadius(int index, int totalItems) {
    if (totalItems == 1) return BorderRadius.circular(20);
    if (index == 0) return const BorderRadius.vertical(top: Radius.circular(20));
    if (index == totalItems - 1) return const BorderRadius.vertical(bottom: Radius.circular(20));
    return BorderRadius.zero;
  }

  void _showLogOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar Akun', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textCharcoal)),
        content: const Text('Apakah Anda yakin ingin keluar dari Sorgummi AI?', style: TextStyle(color: AppColors.textLight)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: AppColors.textLight))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              Navigator.pop(context);
              _doLogout(context);
            },
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }
}

class _MenuData {
  final IconData icon;
  final String title;
  final Widget destination;

  _MenuData({required this.icon, required this.title, required this.destination});
}