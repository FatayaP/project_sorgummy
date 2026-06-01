import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../models/pengelolaan_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database?> get database async {
    // Jika di Web Browser, jangan inisialisasi SQFlite karena tidak didukung
    if (kIsWeb) return null; 
    
    if (_database != null) return _database!;
    _database = await _initDB('pengelolaan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Menggunakan versi 3 agar memicu onUpgrade otomatis untuk tabel saved_articles
    return await openDatabase(
      path, 
      version: 3, 
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    // 1. Tabel Pengelolaan (Bawaan Teman Kelompok)
    await db.execute('''
      CREATE TABLE pengelolaan (
        id $idType,
        activity $textType,
        date $textType,
        notes $textType
      )
    ''');

    // 2. Tabel User Profile (Porsi Zahara)
    await db.execute('''
      CREATE TABLE user_profile (
        id $idType,
        name $textType,
        email $textType,
        phone $textType,
        address $textType
      )
    ''');

    // 3. Tabel Saved Articles (Porsi Zahara - BARU)
    await db.execute('''
      CREATE TABLE saved_articles (
        id $idType,
        title $textType,
        subtitle $textType,
        date $textType,
        image $textType,
        content $textType
      )
    ''');

    // 4. Tabel User Auth untuk login/register dengan hash password
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        name $textType,
        email TEXT NOT NULL UNIQUE,
        phone $textType,
        password $textType
      )
    ''');

    // Masukkan data profil bawaan awal
    await db.insert('user_profile', {
      'id': 1,
      'name': 'Petani Hebat',
      'email': 'petani@sorgummi.com',
      'phone': '081234567890',
      'address': 'Bandung, Jawa Barat',
    });
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_profile (
          id $idType,
          name $textType,
          email $textType,
          phone $textType,
          address $textType
        )
      ''');

      List<Map> count = await db.rawQuery('SELECT COUNT(*) FROM user_profile');
      if (count.first.values.first == 0) {
        await db.insert('user_profile', {
          'id': 1,
          'name': 'Petani Hebat',
          'email': 'petani@sorgummi.com',
          'phone': '081234567890',
          'address': 'Bandung, Jawa Barat',
        });
      }
    }

    if (oldVersion < 3) {
      // Otomatis membuat tabel saved_articles jika aplikasi di-update ke versi terbaru
      await db.execute('''
        CREATE TABLE IF NOT EXISTS saved_articles (
          id $idType,
          title $textType,
          subtitle $textType,
          date $textType,
          image $textType,
          content $textType
        )
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id $idType,
          name $textType,
          email $textType,
          phone $textType,
          password $textType
        )
      ''');
    }
  }

  // =========================================================================
  // OPERASI CRUD TABEL SAVED_ARTICLES (PORSI KERJA ZAHARA)
  // =========================================================================

  // A. SQLITE CREATE / INSERT: Menyimpan artikel baru (Fungsi agar tombol bookmark bisa berfungsi)
  Future<int> insertArticle(Map<String, dynamic> article) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.insert(
      'saved_articles', 
      article,
      conflictAlgorithm: ConflictAlgorithm.replace, // Supaya jika di-bookmark lagi tidak crash melainkan di-replace
    );
  }

  // B. SQLITE READ: Mengambil seluruh daftar artikel tersimpan untuk halaman list
  Future<List<Map<String, dynamic>>> getSavedArticles() async {
    final db = await instance.database;
    if (db == null) return [];
    return await db.query('saved_articles');
  }

  // C. SQLITE DELETE: Menghapus artikel dari database secara rill dengan Swipe Gesture
  Future<int> deleteArticle(String title) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.delete(
      'saved_articles',
      where: 'title = ?',
      whereArgs: [title],
    );
  }

  // =========================================================================
  // OPERASI CRUD TABEL USER_PROFILE (PORSI KERJA ZAHARA)
  // =========================================================================
  Future<Map<String, dynamic>?> getUserProfile() async {
    final db = await instance.database;
    if (db == null) return null; 
    
    final List<Map<String, dynamic>> maps = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );
    
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  Future<int> updateUserProfile(Map<String, dynamic> data) async {
    final db = await instance.database;
    if (db == null) return 0; 
    return await db.update('user_profile', data, where: 'id = ?', whereArgs: [1]);
  }

  Future<int> resetUserProfile() async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.update(
      'user_profile',
      {
        'name': 'Petani Hebat',
        'email': 'petani@sorgummi.com',
        'phone': '081234567890',
        'address': 'Bandung, Jawa Barat',
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // =========================================================================
  // OPERASI CRUD TABEL USERS (AUTH)
  // =========================================================================

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      final String email = user['email']?.toString() ?? '';
      if (email.isEmpty) return 0;
      final Map<String, dynamic> storedUsers = jsonDecode(prefs.getString('web_users') ?? '{}');
      storedUsers[email] = {
        'name': user['name']?.toString() ?? '',
        'email': email,
        'phone': user['phone']?.toString() ?? '',
        'password': _hashPassword(user['password']?.toString() ?? ''),
      };
      await prefs.setString('web_users', jsonEncode(storedUsers));
      return 1;
    }

    final userToInsert = Map<String, dynamic>.from(user);
    userToInsert['password'] = _hashPassword(userToInsert['password']?.toString() ?? '');
    return await db.insert(
      'users',
      userToInsert,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> loginUser(String email, String passwordHash) async {
    final db = await instance.database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      final String rawUsers = prefs.getString('web_users') ?? '{}';
      final Map<String, dynamic> storedUsers = jsonDecode(rawUsers);
      if (!storedUsers.containsKey(email)) return false;
      return storedUsers[email]['password'] == passwordHash;
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, passwordHash],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await instance.database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      final String rawUsers = prefs.getString('web_users') ?? '{}';
      final Map<String, dynamic> storedUsers = jsonDecode(rawUsers);
      if (!storedUsers.containsKey(email)) return null;
      return Map<String, dynamic>.from(storedUsers[email]);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<int> updatePassword(String email, String newPassword) async {
    final hashedPassword = _hashPassword(newPassword);
    final db = await instance.database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      final String rawUsers = prefs.getString('web_users') ?? '{}';
      final Map<String, dynamic> storedUsers = jsonDecode(rawUsers);
      if (!storedUsers.containsKey(email)) return 0;
      storedUsers[email]['password'] = hashedPassword;
      await prefs.setString('web_users', jsonEncode(storedUsers));
      return 1;
    }

    return await db.update(
      'users',
      {'password': hashedPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // =========================================================================
  // OPERASI CRUD TABEL PENGELOLAAN (BAWAAN TEMAN KELOMPOK)
  // =========================================================================
  Future<int> insert(PengelolaanItem item) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.insert('pengelolaan', item.toMap());
  }

  Future<List<PengelolaanItem>> getAllPengelolaan() async {
    final db = await instance.database;
    if (db == null) return [];
    final result = await db.query('pengelolaan', orderBy: 'date DESC');
    return result.map((json) => PengelolaanItem.fromMap(json)).toList();
  }

  Future<int> update(PengelolaanItem item) async {
    final db = await instance.database;
    if (db == null) return 0;
    return db.update('pengelolaan', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.delete('pengelolaan', where: 'id = ?', whereArgs: [id]);
  }
}