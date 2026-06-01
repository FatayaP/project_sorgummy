import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/colors.dart';
import '../../data/helpers/database_helper.dart'; 

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final String currentPhone;
  final String currentAddress;

  const EditProfileScreen({
    Key? key,
    required this.currentName,
    required this.currentEmail,
    required this.currentPhone,
    required this.currentAddress,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
    _phoneController = TextEditingController(text: widget.currentPhone);
    _addressController = TextEditingController(text: widget.currentAddress);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // =========================================================================
  // DYNAMIC PILL TOAST (COMPACT, MELAYANG MINI, & 100% AESTHETIC)
  // =========================================================================
  void _showCompactToast(BuildContext context, String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20, // Melayang anggun di atas
        left: 0,
        right: 0,
        child: Align(
          alignment: Alignment.topCenter, // Kunci utama biar boks tidak memanjang full screen
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: isError ? const Color(0xFFFFF2F2) : const Color(0xFFF2FDF5), // Warna pastel super soft
                borderRadius: BorderRadius.circular(30), // Berbentuk kapsul / pil bulat sempurna
                border: Border.all(
                  color: isError ? Colors.red.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.2), 
                  width: 1
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04), // Efek bayangan super tipis mewah
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // Boks otomatis mengecil mengikuti panjang text!
                children: [
                  Icon(
                    isError ? Icons.error_rounded : Icons.check_circle_rounded,
                    color: isError ? Colors.redAccent : AppColors.primaryGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    message,
                    style: TextStyle(
                      color: isError ? Colors.red.shade900 : const Color(0xFF1B5E20), // Teks kontras gelap elegan
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Hilang otomatis dalam 2.2 detik
    Future.delayed(const Duration(milliseconds: 2200), () {
      overlayEntry.remove();
    });
  }

  // =========================================================================
  // OPERASI SIMPAN DATA (SQLITE / WEB RUNNER)
  // =========================================================================
  Future<void> _saveChanges() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String phone = _phoneController.text.trim();
    final String address = _addressController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      _showCompactToast(context, 'Nama & Email wajib diisi!', isError: true);
      return;
    }

    final Map<String, dynamic> updatedData = {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
    };

    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('web_profile_name', name);
        await prefs.setString('web_profile_email', email);
        await prefs.setString('web_profile_phone', phone);
        await prefs.setString('web_profile_address', address);
      } else {
        await DatabaseHelper.instance.updateUserProfile(updatedData);
      }

      if (mounted) {
        // Tembakkan Notifikasi Kapsul Estetik
        _showCompactToast(
          context, 
          kIsWeb ? 'Profil diperbarui!' : 'Berhasil disimpan ke SQLite!'
        );
        Navigator.pop(context); 
      }
    } catch (e) {
      debugPrint("Gagal mengupdate profil: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: AppBar(
          title: const Text(
            'Edit Profil', 
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField(label: 'Nama Lengkap', controller: _nameController, icon: Icons.person_outline_rounded, hint: 'Masukkan nama lengkap'),
                  const SizedBox(height: 20),
                  _buildInputField(label: 'Alamat Email', controller: _emailController, icon: Icons.email_outlined, hint: 'Masukkan email aktif', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 20),
                  _buildInputField(label: 'Nomor Telepon', controller: _phoneController, icon: Icons.phone_android_rounded, hint: 'Masukkan nomor telepon', keyboardType: TextInputType.phone),
                  const SizedBox(height: 20),
                  _buildInputField(label: 'Alamat Lahan / Domisili', controller: _addressController, icon: Icons.location_on_outlined, hint: 'Masukkan alamat lahan', maxLines: 3),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: _saveChanges, 
                      child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label, 
    required TextEditingController controller, 
    required IconData icon, 
    required String hint, 
    TextInputType keyboardType = TextInputType.text, 
    int maxLines = 1
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8), 
          child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textCharcoal)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardLightGrey.withOpacity(0.6), 
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 14, color: AppColors.textCharcoal, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textLight.withOpacity(0.6), fontSize: 13),
              prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }
}