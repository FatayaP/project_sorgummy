import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static const String _isFirstTimeKey = 'isFirstTime';
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _loggedUserEmailKey = 'logged_user_email';

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

  // --- Logged user helper ---
  static Future<void> setLoggedUserEmail(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loggedUserEmailKey, userEmail);
  }

  static Future<String?> getLoggedUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_loggedUserEmailKey);
  }

  static String _activityKey(String userEmail) => 'activity_logs_$userEmail';

  // =========================================================================
  // Activity log helpers (List<String> of JSON encoded maps)
  // Key per logged-in user: activity_logs_<userEmail>
  // =========================================================================

  // Save a new activity to the top of the list, keep max 20 items
  static Future<void> saveActivity(String action, {String? userEmail}) async {
    try {
      userEmail ??= await getLoggedUserEmail();
      if (userEmail == null || userEmail.isEmpty) {
        debugPrint('SharedPrefsHelper.saveActivity warning: no logged user email available');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final String key = _activityKey(userEmail);
      List<String> logs = prefs.getStringList(key) ?? [];

      final Map<String, String> newLog = {
        'action': action,
        'time': DateTime.now().toString().substring(0, 16),
      };

      logs.insert(0, jsonEncode(newLog));

      if (logs.length > 20) {
        logs = logs.sublist(0, 20);
      }

      await prefs.setStringList(key, logs);
    } catch (e) {
      debugPrint('SharedPrefsHelper.saveActivity error: $e');
    }
  }

  // Return the list of activity JSON strings for the current user
  static Future<List<String>> getActivityLogs({String? userEmail}) async {
    userEmail ??= await getLoggedUserEmail();
    if (userEmail == null || userEmail.isEmpty) {
      return [];
    }

    final prefs = await SharedPreferences.getInstance();
    final String key = _activityKey(userEmail);
    return prefs.getStringList(key) ?? [];
  }

  // Clear activity logs for the current user only
  static Future<void> clearActivityLogs({String? userEmail}) async {
    userEmail ??= await getLoggedUserEmail();
    if (userEmail == null || userEmail.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String key = _activityKey(userEmail);
    await prefs.remove(key);
  }
}