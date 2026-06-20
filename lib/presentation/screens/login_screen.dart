import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/colors.dart';
import '../../data/helpers/database_helper.dart';
import '../../data/helpers/shared_prefs_helper.dart';
import '../../admin/admin_dashboard_page.dart';
import 'main_navigation.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMeEmail();
  }

  Future<void> _loadRememberMeEmail() async {
    final String? savedEmail = await SharedPrefsHelper.getRememberMeEmail();
    debugPrint('🔍 LoadRememberMeEmail: savedEmail = $savedEmail');
    if (savedEmail != null && savedEmail.isNotEmpty) {
      _emailController.text = savedEmail;
      setState(() {
        _rememberMe = true;
      });
      debugPrint('✅ Email auto-filled dari saved data');
    } else {
      debugPrint('❌ Tidak ada email yang tersimpan');
    }
  }

  Future<void> _saveRememberMeEmail(String email) async {
    debugPrint('💾 SaveRememberMeEmail: _rememberMe = $_rememberMe, email = $email');
    if (_rememberMe) {
      await SharedPrefsHelper.setRememberMeEmail(email);
      debugPrint('✅ Email berhasil disimpan: $email');
    } else {
      await SharedPrefsHelper.clearRememberMeEmail();
      debugPrint('❌ Email dihapus karena checkbox OFF');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // KREDENSIAL ADMIN — jangan ada spasi tersembunyi di antara tanda kutip!
  // ════════════════════════════════════════════════════════════════════════════
  static const String _kAdminEmail    = 'admin123@gmail.com';
  static const String _kAdminPassword = 'admin123';

  // ─── Helper: apakah input cocok dengan kredensial admin? ────────────────────
  bool _isAdminCredential(String email, String password) {
    // .trim() di KEDUA sisi: input user & konstanta — 100% aman dari spasi
    final inputEmail    = email.trim().toLowerCase();
    final inputPassword = password.trim();
    final targetEmail   = _kAdminEmail.trim().toLowerCase();
    final targetPass    = _kAdminPassword.trim();

    // Debug diagnostik — lihat di konsol Flutter untuk memastikan nilai cocok
    debugPrint('╔══ ADMIN CHECK ══════════════════════════════');
    debugPrint('║  inputEmail    : "$inputEmail"   (len=${inputEmail.length})');
    debugPrint('║  targetEmail   : "$targetEmail" (len=${targetEmail.length})');
    debugPrint('║  emailMatch    : ${inputEmail == targetEmail}');
    debugPrint('║  inputPassword : "$inputPassword" (len=${inputPassword.length})');
    debugPrint('║  targetPass    : "$targetPass"  (len=${targetPass.length})');
    debugPrint('║  passMatch     : ${inputPassword == targetPass}');
    debugPrint('╚═════════════════════════════════════════════');

    return inputEmail == targetEmail && inputPassword == targetPass;
  }

  // ─── Fungsi utama login — dipanggil oleh onPressed tombol Sign In ───────────
  Future<void> _doLogin() async {
    // 1. Validasi form (field kosong / format email salah)
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // 2. Ambil nilai input — .trim() mencegah spasi tersembunyi
    final String emailInput    = _emailController.text.trim();
    final String passwordInput = _passwordController.text.trim();

    debugPrint('🔐 Sign In ditekan — email="$emailInput", rememberMe=$_rememberMe');

    try {
      // ════════════════════════════════════════════════════════════════════════
      // GERBANG PERTAMA ▸ CEK ADMIN (selalu diperiksa paling awal)
      // ════════════════════════════════════════════════════════════════════════
      if (_isAdminCredential(emailInput, passwordInput)) {
        debugPrint('🛡️  ADMIN TERDETEKSI — Memproses sesi admin...');

        final prefs = await SharedPreferences.getInstance();

        // Simpan role & status sesi
        await prefs.setString('user_role', 'admin');
        await prefs.setBool('is_logged_in', true);
        await SharedPrefsHelper.setLoggedUserEmail(_kAdminEmail);

        // Reminder me nexttime: simpan / hapus email sesuai posisi switch
        if (_rememberMe) {
          await SharedPrefsHelper.setRememberMeEmail(_kAdminEmail);
          debugPrint('💾 Remember-me: email admin disimpan');
        } else {
          await SharedPrefsHelper.clearRememberMeEmail();
          debugPrint('🗑️  Remember-me: email admin dihapus');
        }

        await SharedPrefsHelper.saveActivity('Admin berhasil masuk ke panel admin');

        if (!mounted) return;

        // Navigasi ke Admin Dashboard — hapus semua route sebelumnya
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
          (route) => false,
        );

        return; // ← WAJIB: hentikan di sini, jangan lanjut ke blok user biasa
      }

      // ════════════════════════════════════════════════════════════════════════
      // GERBANG KEDUA ▸ LOGIN USER BIASA via Database
      // ════════════════════════════════════════════════════════════════════════
      debugPrint('👤 Bukan admin — mencoba login user biasa...');

      // TODO: Login User Biasa
      final String passwordHash = _hashPassword(passwordInput);
      final bool success = await DatabaseHelper.instance.loginUser(
        emailInput.toLowerCase(), // normalisasi email sebelum query DB
        passwordHash,
      );

      if (success) {
        debugPrint('✅ Login user biasa BERHASIL');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', 'user');
        await prefs.setBool('is_logged_in', true);
        await SharedPrefsHelper.setLoggedIn(true);
        await SharedPrefsHelper.setLoggedUserEmail(emailInput.toLowerCase());
        await SharedPrefsHelper.setFirstTime(false);
        await _saveRememberMeEmail(emailInput.toLowerCase());
        await SharedPrefsHelper.saveActivity('Berhasil masuk ke dalam aplikasi');

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
          (route) => false,
        );
      } else {
        debugPrint('❌ Login GAGAL: email atau password tidak cocok di DB');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email atau password salah.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('🔥 Exception saat login: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF263238)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360.0),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/login.png',
                        height: 120.0,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120.0,
                            width: 120.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7F5),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: const Icon(
                              Icons.security,
                              size: 60.0,
                              color: AppColors.primaryGreen,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Please Sign in to continue.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.grey,
                          size: 22,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F6F9),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email wajib diisi';
                        }
                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+',
                        ).hasMatch(value.trim())) {
                          return 'Email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.grey,
                          size: 22,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F6F9),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Password wajib diisi';
                        }
                        if (value.trim().length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Reminder me nextime',
                          style: TextStyle(
                            color: Color(0xFF263238),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Transform.scale(
                          scale: 0.75,
                          child: Switch(
                            value: _rememberMe,
                            activeColor: Colors.white,
                            activeTrackColor: AppColors.primaryGreen,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.grey.shade300,
                            onChanged: (bool value) {
                              setState(() {
                                _rememberMe = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(23.0),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isLoading ? null : _doLogin,
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontFamily: 'sans-serif',
                            ),
                            children: [
                              TextSpan(text: "Don't have account? "),
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
