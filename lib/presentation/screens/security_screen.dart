import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/colors.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({Key? key}) : super(key: key);

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller untuk mengambil data input teks
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  // State untuk kontrol visibilitas password (mengubah ikon mata)
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // Fungsi Logika untuk Memperbarui Password secara rill ke Storage Perangkat
  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) {
      return; // Batalkan jika validasi form gagal
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Ambil password lama rill yang tersimpan (jika belum ada, default-nya 'password123')
      String currentSavedPassword = prefs.getString('user_password') ?? 'password123';

      if (_oldPasswordController.text != currentSavedPassword) {
        if (mounted) {
          _showSnackBar('Password lama yang Anda masukkan salah!', isError: true);
        }
        setState(() => _isLoading = false);
        return;
      }

      // Simpan password baru ke lokal
      await prefs.setString('user_password', _newPasswordController.text);

      if (mounted) {
        _showSnackBar('Password berhasil diperbarui secara permanen!');
        // Bersihkan field setelah sukses
        _oldPasswordController.clear();
        _newPasswordController.clear();
        
        // Opsional: Tutup halaman kembali ke profil setelah 1.5 detik sukses
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Terjadi kesalahan, coba lagi nanti.', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isError ? Colors.redAccent : AppColors.textCharcoal,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: AppBar(
          title: const Text(
            'Keamanan & Password', 
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ubah Password Anda',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textCharcoal),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pastikan gunakan gabungan huruf dan angka agar akun tetap aman.',
                    style: TextStyle(fontSize: 13, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 24),

                  // Field Password Lama
                  TextFormField(
                    controller: _oldPasswordController,
                    obscureText: _obscureOldPassword,
                    style: const TextStyle(fontSize: 14, color: AppColors.textCharcoal),
                    decoration: InputDecoration(
                      labelText: 'Password Lama',
                      labelStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textLight, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureOldPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textLight,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureOldPassword = !_obscureOldPassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.dividerGrey)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.cardLightGrey)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5)),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Password lama wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Field Password Baru
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    style: const TextStyle(fontSize: 14, color: AppColors.textCharcoal),
                    decoration: InputDecoration(
                      labelText: 'Password Baru',
                      labelStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
                      prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.textLight, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textLight,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.dividerGrey)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.cardLightGrey)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5)),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Password baru wajib diisi';
                      }
                      if (value.trim().length < 6) {
                        return 'Password baru minimal harus 6 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Tombol Aksi Update Password
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: _isLoading ? null : _updatePassword,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Update Password',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}