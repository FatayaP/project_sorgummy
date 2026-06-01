import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
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
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isSaving = false;

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

  // LOGIKA UTAMA SIMPAN DATA (SQLITE + TRIGER KEY KE-2 SHAREDPREFS)
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updatedData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? loggedEmail = prefs.getString('logged_user_email')?.trim();
      final String newEmailNormalized = updatedData['email']!
          .trim()
          .toLowerCase();

      if (kIsWeb) {
        // Jalur Web Browser
        await prefs.setString('web_profile_name', updatedData['name']!);
        await prefs.setString('web_profile_email', updatedData['email']!);
        await prefs.setString('web_profile_phone', updatedData['phone']!);
        await prefs.setString('web_profile_address', updatedData['address']!);
        // Jika user sedang login di web, update juga entri web_users
        if (loggedEmail != null && loggedEmail.isNotEmpty) {
          await DatabaseHelper.instance.updateUserByEmail(
            updatedData,
            loggedEmail,
          );
          // Jika email berubah, perbarui key logged_user_email
          if (loggedEmail.toLowerCase() != newEmailNormalized) {
            await prefs.setString('logged_user_email', newEmailNormalized);
          }
        }
      } else {
        // Jalur Android Emulator SQLite Rill
        final int profileUpdated = await DatabaseHelper.instance
            .insertOrUpdateUserProfile(updatedData);
        if (profileUpdated == 0) {
          throw Exception('Gagal memperbarui profil lokal');
        }

        // Jika ada akun yang sedang login, pastikan tabel users juga diperbarui
        if (loggedEmail != null && loggedEmail.isNotEmpty) {
          await DatabaseHelper.instance.updateUserByEmail(
            updatedData,
            loggedEmail,
          );
          if (loggedEmail.toLowerCase() != newEmailNormalized) {
            await prefs.setString('logged_user_email', newEmailNormalized);
          }
        }
      }

      // SYARAT DOSEN: Update Key Ke-2 SharedPreferences (Waktu Update)
      await prefs.setString('profile_last_updated', DateTime.now().toString());

      _showCompactTopToast('Perubahan profil berhasil disimpan!');

      // Beri jeda 1 detik agar toast kelihatan sebelum menutup halaman
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        Navigator.pop(
          context,
          true,
        ); // Kembali ke halaman profil sambil memicu refresh data
      }
    } catch (e) {
      debugPrint("Gagal mengupdate profil: $e");
      final String errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('unique constraint') ||
          errorMessage.contains('email')) {
        _showCompactTopToast(
          'Email sudah digunakan, gunakan email lain',
          isError: true,
        );
      } else {
        _showCompactTopToast(
          'Terjadi kesalahan, gagal menyimpan',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // CUSTOM WIDGET 1: Kapsul Toast Melayang Elegan
  void _showCompactTopToast(String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 0,
        right: 0,
        child: Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: isError
                    ? const Color(0xFFFFF2F2)
                    : const Color(0xFFF2FDF5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isError
                      ? Colors.red.withOpacity(0.2)
                      : AppColors.primaryGreen.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
                      color: isError
                          ? Colors.red.shade900
                          : const Color(0xFF1B5E20),
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
    Future.delayed(
      const Duration(milliseconds: 2200),
      () => overlayEntry.remove(),
    );
  }

  // CUSTOM WIDGET 2: Form Input Field Kustom (Syarat Komponen Nilai Dosen)
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textCharcoal,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textCharcoal,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(prefixIcon, color: AppColors.textLight, size: 20),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            fillColor: Colors.white,
            filled: true,
            hintText: 'Masukkan $label Anda',
            hintStyle: TextStyle(
              color: AppColors.textLight.withOpacity(0.5),
              fontSize: 13,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.cardLightGrey,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primaryGreen,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red.shade300, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors
          .backgroundWhite, // Di dalam Scaffold dengan benar, bebas eror!
      appBar: AppBar(
        title: const Text(
          'Ubah Profil',
          style: TextStyle(
            color: AppColors.textCharcoal,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textCharcoal),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isSaving
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            )
          : ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildInputField(
                        controller: _nameController,
                        label: 'Nama Lengkap',
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Nama tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        controller: _emailController,
                        label: 'Alamat Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty)
                            return 'Email tidak boleh kosong';
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value.trim()))
                            return 'Format email salah';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        controller: _phoneController,
                        label: 'Nomor Telepon',
                        prefixIcon: Icons.phone_android_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Nomor telepon tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        controller: _addressController,
                        label: 'Alamat Tempat Tinggal',
                        prefixIcon: Icons.location_on_outlined,
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Alamat tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 40),

                      // TOMBOL EKSEKUSI UTAMA (SIMPAN)
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _saveChanges,
                          child: const Text(
                            'Simpan Perubahan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
