import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static const String _isFirstTimeKey = 'isFirstTime';
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _keyActivityLogs = 'user_activity_logs';

  // --- First time flags ---
  static Future<void> setFirstTime(bool isFirstTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstTimeKey, isFirstTime);
  }

  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstTimeKey) ?? true;
  }

  // --- Logged in ---
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // =========================================================================
  // Activity log helpers (List<String> of JSON encoded maps)
  // Key: 'user_activity_logs'
  // =========================================================================

  // Save a new activity to the top of the list, keep max 20 items
  static Future<void> saveActivity(String action) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> logs = prefs.getStringList(_keyActivityLogs) ?? [];

      final Map<String, String> newLog = {
        'action': action,
        'time': DateTime.now().toString().substring(0, 16),
      };

      logs.insert(0, jsonEncode(newLog));

      if (logs.length > 20) {
        logs = logs.sublist(0, 20);
      }

      await prefs.setStringList(_keyActivityLogs, logs);
    } catch (e) {
      // don't rethrow; just log
      debugPrint('SharedPrefsHelper.saveActivity error: $e');
    }
  }

  // Return the list of activity JSON strings (empty list when none)
  static Future<List<String>> getActivityLogs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyActivityLogs) ?? [];
  }

  // Clear activity logs
  static Future<void> clearActivityLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyActivityLogs);
  }
}