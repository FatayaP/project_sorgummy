import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../models/pengelolaan_item.dart';
import 'shared_prefs_helper.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Key SharedPreferences untuk web fallback (kIsWeb = true)
// ─────────────────────────────────────────────────────────────────────────────
const String _kWebEdukasiKey      = 'web_table_edukasi';
const String _kWebPengelolaanKey  = 'web_table_pengelolaan';

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

    // Versi 6: field artikel diperluas (masalah, langkah_solusi, thumbnail, dll) dan daily_notes drawing_path
    return await openDatabase(
      path,
      version: 6,
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

    // 5. Tabel Edukasi Admin — skema lengkap versi 6
    await db.execute('''
      CREATE TABLE table_edukasi (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        judul           TEXT NOT NULL DEFAULT '',
        kategori        TEXT NOT NULL DEFAULT '',
        status          TEXT NOT NULL DEFAULT 'Active',
        estimasi_baca   TEXT NOT NULL DEFAULT '',
        badge           TEXT NOT NULL DEFAULT '',
        judul_langkah   TEXT NOT NULL DEFAULT '',
        masalah         TEXT NOT NULL DEFAULT '',
        penyebab        TEXT NOT NULL DEFAULT '',
        langkah_solusi  TEXT NOT NULL DEFAULT '[]',
        tips_ahli       TEXT NOT NULL DEFAULT '',
        konten          TEXT NOT NULL DEFAULT '',
        thumbnail       TEXT NOT NULL DEFAULT '',
        views           INTEGER NOT NULL DEFAULT 0,
        tanggal         TEXT NOT NULL DEFAULT ''
      )
    ''');

    // 6. Tabel Pengelolaan Admin — skema lengkap versi 6
    await db.execute('''
      CREATE TABLE table_pengelolaan (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        judul           TEXT NOT NULL DEFAULT '',
        kategori        TEXT NOT NULL DEFAULT '',
        status          TEXT NOT NULL DEFAULT 'Active',
        estimasi_baca   TEXT NOT NULL DEFAULT '',
        badge           TEXT NOT NULL DEFAULT '',
        judul_langkah   TEXT NOT NULL DEFAULT '',
        masalah         TEXT NOT NULL DEFAULT '',
        penyebab        TEXT NOT NULL DEFAULT '',
        langkah_solusi  TEXT NOT NULL DEFAULT '[]',
        tips_ahli       TEXT NOT NULL DEFAULT '',
        konten          TEXT NOT NULL DEFAULT '',
        thumbnail       TEXT NOT NULL DEFAULT '',
        views           INTEGER NOT NULL DEFAULT 0,
        tanggal         TEXT NOT NULL DEFAULT ''
      )
    ''');

    // 7. Tabel Search History (Riwayat Pencarian)
    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL UNIQUE,
        timestamp INTEGER NOT NULL
      )
    ''');

    // 8. Tabel Daily Notes (Catatan Harian)
    await db.execute('''
      CREATE TABLE daily_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title $textType,
        category $textType,
        content $textType,
        date $textType,
        drawing_path TEXT
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

    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS table_edukasi (
          id       $idType,
          judul    $textType,
          kategori $textType,
          konten   $textType,
          views    INTEGER NOT NULL DEFAULT 0,
          status   TEXT NOT NULL DEFAULT 'Aktif',
          tanggal  $textType
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS table_pengelolaan (
          id       $idType,
          judul    $textType,
          kategori $textType,
          konten   $textType,
          views    INTEGER NOT NULL DEFAULT 0,
          status   TEXT NOT NULL DEFAULT 'Aktif',
          tanggal  $textType
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS search_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          query TEXT NOT NULL UNIQUE,
          timestamp INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS daily_notes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title $textType,
          category $textType,
          content $textType,
          date $textType,
          drawing_path TEXT
        )
      ''');
    }

    // ── Versi 6: kolom baru untuk form artikel kaya field ───────────────
    if (oldVersion < 6) {
      for (final table in ['table_edukasi', 'table_pengelolaan']) {
        try {
          await db.execute("ALTER TABLE $table ADD COLUMN estimasi_baca TEXT NOT NULL DEFAULT ''");
          await db.execute("ALTER TABLE $table ADD COLUMN badge TEXT NOT NULL DEFAULT ''");
          await db.execute("ALTER TABLE $table ADD COLUMN judul_langkah TEXT NOT NULL DEFAULT ''");
          await db.execute("ALTER TABLE $table ADD COLUMN masalah TEXT NOT NULL DEFAULT ''");
          await db.execute("ALTER TABLE $table ADD COLUMN penyebab TEXT NOT NULL DEFAULT ''");
          await db.execute("ALTER TABLE $table ADD COLUMN langkah_solusi TEXT NOT NULL DEFAULT '[]'");
          await db.execute("ALTER TABLE $table ADD COLUMN tips_ahli TEXT NOT NULL DEFAULT ''");
          await db.execute("ALTER TABLE $table ADD COLUMN thumbnail TEXT NOT NULL DEFAULT ''");
        } catch (e) {
          // Abaikan jika kolom sudah ada
        }
      }
      try {
        await db.execute('ALTER TABLE daily_notes ADD COLUMN drawing_path TEXT');
      } catch (e) {
        // Abaikan jika kolom sudah ada
      }
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
      conflictAlgorithm: ConflictAlgorithm
          .replace, // Supaya jika di-bookmark lagi tidak crash melainkan di-replace
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
    return await db.update(
      'user_profile',
      data,
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<int> insertUserProfile(Map<String, dynamic> data) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.insert(
      'user_profile',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertOrUpdateUserProfile(Map<String, dynamic> data) async {
    final existingProfile = await getUserProfile();
    if (existingProfile == null) {
      return await insertUserProfile(data);
    }
    return await updateUserProfile(data);
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
    final String normalizedEmail =
        user['email']?.toString().trim().toLowerCase() ?? '';
    if (normalizedEmail.isEmpty) return 0;

    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> storedUsers = jsonDecode(
        prefs.getString('web_users') ?? '{}',
      );
      storedUsers[normalizedEmail] = {
        'name': user['name']?.toString() ?? '',
        'email': normalizedEmail,
        'phone': user['phone']?.toString() ?? '',
        'password': _hashPassword(user['password']?.toString() ?? ''),
      };
      await prefs.setString('web_users', jsonEncode(storedUsers));
      return 1;
    }

    final userToInsert = Map<String, dynamic>.from(user);
    userToInsert['email'] = normalizedEmail;
    userToInsert['password'] = _hashPassword(
      userToInsert['password']?.toString() ?? '',
    );
    return await db.insert(
      'users',
      userToInsert,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> loginUser(String email, String passwordHash) async {
    final String normalizedEmail = email.trim().toLowerCase();
    final db = await instance.database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      final String rawUsers = prefs.getString('web_users') ?? '{}';
      final Map<String, dynamic> storedUsers = jsonDecode(rawUsers);
      if (!storedUsers.containsKey(normalizedEmail)) return false;
      return storedUsers[normalizedEmail]['password'] == passwordHash;
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [normalizedEmail, passwordHash],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final String normalizedEmail = email.trim().toLowerCase();
    final db = await instance.database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      final String rawUsers = prefs.getString('web_users') ?? '{}';
      final Map<String, dynamic> storedUsers = jsonDecode(rawUsers);
      if (!storedUsers.containsKey(normalizedEmail)) return null;
      return Map<String, dynamic>.from(storedUsers[normalizedEmail]);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<int> updatePassword(String email, String newPassword) async {
    final String normalizedEmail = email.trim().toLowerCase();
    final hashedPassword = _hashPassword(newPassword);
    final db = await instance.database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      final String rawUsers = prefs.getString('web_users') ?? '{}';
      final Map<String, dynamic> storedUsers = jsonDecode(rawUsers);
      if (!storedUsers.containsKey(normalizedEmail)) return 0;
      storedUsers[normalizedEmail]['password'] = hashedPassword;
      await prefs.setString('web_users', jsonEncode(storedUsers));
      return 1;
    }

    return await db.update(
      'users',
      {'password': hashedPassword},
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );
  }

  /// Update user record by email. If running on web (db == null), updates
  /// the `web_users` map stored in SharedPreferences. Returns number of
  /// affected records (1 = success, 0 = not found).
  Future<int> updateUserByEmail(Map<String, dynamic> data, String email) async {
    final String normalizedEmail = email.trim().toLowerCase();
    final db = await instance.database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      final String rawUsers = prefs.getString('web_users') ?? '{}';
      final Map<String, dynamic> storedUsers = jsonDecode(rawUsers);
      if (!storedUsers.containsKey(normalizedEmail)) return 0;

      final Map<String, dynamic> user = Map<String, dynamic>.from(
        storedUsers[normalizedEmail],
      );
      // Update fields if provided
      if (data.containsKey('name')) {
        user['name'] = data['name']?.toString() ?? user['name'];
      }
      if (data.containsKey('email')) {
        user['email'] =
            data['email']?.toString().trim().toLowerCase() ?? user['email'];
      }
      if (data.containsKey('phone')) {
        user['phone'] = data['phone']?.toString() ?? user['phone'];
      }

      // If email changed, we need to move the key
      final String newEmailKey = user['email'].toString().trim().toLowerCase();
      storedUsers.remove(normalizedEmail);
      storedUsers[newEmailKey] = user;
      await prefs.setString('web_users', jsonEncode(storedUsers));
      return 1;
    }

    final Map<String, dynamic> toUpdate = {};

    if (data.containsKey('name')) {
      toUpdate['name'] = data['name']?.toString() ?? '';
    }
    if (data.containsKey('email')) {
      toUpdate['email'] = data['email']?.toString().trim().toLowerCase() ?? '';
    }
    if (data.containsKey('phone')) {
      toUpdate['phone'] = data['phone']?.toString() ?? '';
    }

    if (toUpdate.isEmpty) {
      return 0;
    }

    return await db.update(
      'users',
      toUpdate,
      where: 'email = ?',
      whereArgs: [normalizedEmail],
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
    return db.update(
      'pengelolaan',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.delete('pengelolaan', where: 'id = ?', whereArgs: [id]);
  }

  // ===========================================================================
  // CRUD TABLE_EDUKASI  (Admin → dibaca juga oleh sisi User)
  // ===========================================================================

  /// INSERT: Simpan artikel edukasi baru ke SQLite.
  /// Di web (kIsWeb), data disimpan sebagai JSON list di SharedPreferences.
  Future<int> insertEdukasi(Map<String, dynamic> row) async {
    final db = await instance.database;
    if (db == null) {
      // Web fallback
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> list = jsonDecode(prefs.getString(_kWebEdukasiKey) ?? '[]');
      final int newId = list.isEmpty ? 1 : (list.last['id'] as int) + 1;
      list.add({...row, 'id': newId});
      await prefs.setString(_kWebEdukasiKey, jsonEncode(list));
      return newId;
    }
    return await db.insert('table_edukasi', row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// READ: Ambil semua artikel edukasi, diurutkan terbaru di atas.
  Future<List<Map<String, dynamic>>> queryAllEdukasi() async {
    final db = await instance.database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> list = jsonDecode(prefs.getString(_kWebEdukasiKey) ?? '[]');
      return list.reversed
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return await db.query('table_edukasi', orderBy: 'id DESC');
  }

  /// UPDATE: Perbarui artikel edukasi berdasarkan id.
  Future<int> updateEdukasi(Map<String, dynamic> row) async {
    final db = await instance.database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> list = jsonDecode(prefs.getString(_kWebEdukasiKey) ?? '[]');
      final int idx = list.indexWhere((e) => e['id'] == row['id']);
      if (idx == -1) return 0;
      list[idx] = row;
      await prefs.setString(_kWebEdukasiKey, jsonEncode(list));
      return 1;
    }
    return await db.update(
      'table_edukasi',
      row,
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }

  /// DELETE: Hapus artikel edukasi berdasarkan id.
  Future<int> deleteEdukasi(int id) async {
    final db = await instance.database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> list = jsonDecode(prefs.getString(_kWebEdukasiKey) ?? '[]');
      final int before = list.length;
      list.removeWhere((e) => e['id'] == id);
      await prefs.setString(_kWebEdukasiKey, jsonEncode(list));
      return before - list.length; // 1 jika berhasil dihapus
    }
    return await db.delete('table_edukasi', where: 'id = ?', whereArgs: [id]);
  }

  // ===========================================================================
  // CRUD TABLE_PENGELOLAAN  (Admin → dibaca juga oleh sisi User)
  // ===========================================================================

  /// INSERT: Simpan panduan pengelolaan baru ke SQLite.
  Future<int> insertPengelolaanAdmin(Map<String, dynamic> row) async {
    final db = await instance.database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> list = jsonDecode(prefs.getString(_kWebPengelolaanKey) ?? '[]');
      final int newId = list.isEmpty ? 1 : (list.last['id'] as int) + 1;
      list.add({...row, 'id': newId});
      await prefs.setString(_kWebPengelolaanKey, jsonEncode(list));
      return newId;
    }
    return await db.insert('table_pengelolaan', row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// READ: Ambil semua panduan pengelolaan, terbaru di atas.
  Future<List<Map<String, dynamic>>> queryAllPengelolaanAdmin() async {
    final db = await instance.database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> list = jsonDecode(prefs.getString(_kWebPengelolaanKey) ?? '[]');
      return list.reversed
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return await db.query('table_pengelolaan', orderBy: 'id DESC');
  }

  /// UPDATE: Perbarui panduan pengelolaan berdasarkan id.
  Future<int> updatePengelolaanAdmin(Map<String, dynamic> row) async {
    final db = await instance.database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> list = jsonDecode(prefs.getString(_kWebPengelolaanKey) ?? '[]');
      final int idx = list.indexWhere((e) => e['id'] == row['id']);
      if (idx == -1) return 0;
      list[idx] = row;
      await prefs.setString(_kWebPengelolaanKey, jsonEncode(list));
      return 1;
    }
    return await db.update(
      'table_pengelolaan',
      row,
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }

  /// DELETE: Hapus panduan pengelolaan berdasarkan id.
  Future<int> deletePengelolaanAdmin(int id) async {
    final db = await instance.database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> list = jsonDecode(prefs.getString(_kWebPengelolaanKey) ?? '[]');
      final int before = list.length;
      list.removeWhere((e) => e['id'] == id);
      await prefs.setString(_kWebPengelolaanKey, jsonEncode(list));
      return before - list.length;
    }
    return await db.delete('table_pengelolaan', where: 'id = ?', whereArgs: [id]);
  }

  // =========================================================================
  // OPERASI CRUD TABEL SEARCH_HISTORY (RIWAYAT PENCARIAN)
  // =========================================================================

  // A. SQLITE CREATE: Menyimpan kata kunci pencarian baru ke tabel search_history
  Future<int> insertSearchHistory(String query) async {
    final db = await instance.database;
    if (db == null) {
      // Fallback untuk Web
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList('web_search_history') ?? [];
      history.remove(query);
      history.insert(0, query);

      final limit = prefs.getInt('search_history_limit') ?? 10;
      if (history.length > limit) {
        history = history.sublist(0, limit);
      }
      await prefs.setStringList('web_search_history', history);
      return 1;
    }

    final limit = await SharedPrefsHelper.getSearchHistoryLimit();

    return await db.transaction((txn) async {
      // Hapus jika query yang sama sudah ada agar timestamp baru berada di paling atas
      await txn.delete('search_history', where: 'query = ?', whereArgs: [query]);

      final id = await txn.insert('search_history', {
        'query': query,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      // Hapus riwayat yang lebih lama jika jumlahnya melebihi limit
      final List<Map<String, dynamic>> countResult =
          await txn.rawQuery('SELECT COUNT(*) as count FROM search_history');
      final count = countResult.first['count'] as int;

      if (count > limit) {
        final List<Map<String, dynamic>> boundaryResult = await txn.query(
          'search_history',
          columns: ['timestamp'],
          orderBy: 'timestamp DESC',
          limit: 1,
          offset: limit - 1,
        );
        if (boundaryResult.isNotEmpty) {
          final boundaryTime = boundaryResult.first['timestamp'] as int;
          await txn.delete(
            'search_history',
            where: 'timestamp < ?',
            whereArgs: [boundaryTime],
          );
        }
      }
      return id;
    });
  }

  // B. SQLITE READ: Menampilkan riwayat pencarian terakhir
  Future<List<String>> getSearchHistory() async {
    final db = await instance.database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('web_search_history') ?? [];
    }

    final limit = await SharedPrefsHelper.getSearchHistoryLimit();

    final List<Map<String, dynamic>> maps = await db.query(
      'search_history',
      columns: ['query'],
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return maps.map((map) => map['query'] as String).toList();
  }

  // C. SQLITE DELETE: Menghapus satu atau semua riwayat pencarian
  Future<int> deleteSearchHistoryItem(String query) async {
    final db = await instance.database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList('web_search_history') ?? [];
      history.remove(query);
      await prefs.setStringList('web_search_history', history);
      return 1;
    }

    return await db.delete(
      'search_history',
      where: 'query = ?',
      whereArgs: [query],
    );
  }

  Future<int> clearAllSearchHistory() async {
    final db = await instance.database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('web_search_history');
      return 1;
    }

    return await db.delete('search_history');
  }

  // =========================================================================
  // OPERASI CRUD TABEL DAILY_NOTES (CATATAN HARIAN)
  // =========================================================================

  Future<int> insertDailyNote(Map<String, dynamic> note) async {
    final db = await instance.database;
    if (db == null) {
      // Fallback untuk Web
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> notes = await getDailyNotesWeb();
      int newId = notes.isEmpty ? 1 : (notes.map((n) => n['id'] as int).reduce((a, b) => a > b ? a : b) + 1);
      final noteWithId = Map<String, dynamic>.from(note);
      noteWithId['id'] = newId;
      notes.add(noteWithId);
      await prefs.setString('web_daily_notes', jsonEncode(notes));
      return newId;
    }
    return await db.insert('daily_notes', note);
  }

  Future<List<Map<String, dynamic>>> getDailyNotesWeb() async {
    final prefs = await SharedPreferences.getInstance();
    final String raw = prefs.getString('web_daily_notes') ?? '[]';
    final List<dynamic> list = jsonDecode(raw);
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getDailyNotes() async {
    final db = await instance.database;
    if (db == null) {
      return await getDailyNotesWeb();
    }
    return await db.query('daily_notes');
  }

  Future<int> updateDailyNote(Map<String, dynamic> note) async {
    final db = await instance.database;
    final int id = note['id'] as int;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> notes = await getDailyNotesWeb();
      int index = notes.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        notes[index] = note;
        await prefs.setString('web_daily_notes', jsonEncode(notes));
        return 1;
      }
      return 0;
    }
    return await db.update(
      'daily_notes',
      note,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteDailyNote(int id) async {
    final db = await instance.database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> notes = await getDailyNotesWeb();
      notes.removeWhere((n) => n['id'] == id);
      await prefs.setString('web_daily_notes', jsonEncode(notes));
      return 1;
    }
    return await db.delete(
      'daily_notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
