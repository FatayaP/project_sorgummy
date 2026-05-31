import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class EditProfileScreen extends StatefulWidget {
  // Tambahkan parameter untuk menerima data profil saat ini agar form tidak kosong saat dibuka
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
    // Mengisi form langsung dengan data saat ini
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

  void _saveChanges() {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dan Email tidak boleh kosong!'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // KUNCI UTAMA: Mengirimkan map data baru kembali ke ProfileScreen saat halaman ditutup
    Navigator.pop(context, {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: AppBar(
          title: const Text('Edit Profil', style: TextStyle(color: AppColors.textCharcoal, fontSize: 18, fontWeight: FontWeight.bold)),
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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
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
      ),
    );
  }

  Widget _buildInputField({required String label, required TextEditingController controller, required IconData icon, required String hint, TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textCharcoal))),
        Container(
          decoration: BoxDecoration(color: AppColors.cardLightGrey.withOpacity(0.6), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardLightGrey)),
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