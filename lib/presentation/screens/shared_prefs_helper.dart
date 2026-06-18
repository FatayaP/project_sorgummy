import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static const String _keyLoggedIn = "is_logged_in";
  static const String _keyActivityLogs = "user_activity_logs";

  // --- Fungsi Login Bawaan Kelompokmu ---
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  // =========================================================================
  // CORE LOGGER: Menyimpan riwayat aktivitas dalam format List JSON String
  // =========================================================================
  
  // Fungsi untuk menyimpan aktivitas baru
  static Future<void> saveActivity(String action) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Ambil daftar lama
      List<String> logs = prefs.getStringList(_keyActivityLogs) ?? [];
      
      // Bungkus aktivitas baru ke format JSON
      Map<String, String> newLog = {
        'action': action,
        'time': DateTime.now().toString().substring(0, 16), // Hasil: YYYY-MM-DD HH:mm
      };
      
      // Selipkan ke urutan teratas (index 0)
      logs.insert(0, jsonEncode(newLog));
      
      // Batasi maksimal 20 catatan saja agar hemat memori
      if (logs.length > 20) {
        logs = logs.sublist(0, 20);
      }
      
      await prefs.setStringList(_keyActivityLogs, logs);
    } catch (e) {
      print("Gagal menyimpan log aktivitas: $e");
    }
  }

  // Fungsi untuk mengambil log riwayat (Menghilangkan eror merah di screen! ✅)
  static Future<List<String>> getActivityLogs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyActivityLogs) ?? [];
  }

  // Fungsi untuk menghapus semua log riwayat (Menghilangkan eror merah di screen! ✅)
  static Future<void> clearActivityLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyActivityLogs);
  }
}