import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pengelolaan_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pengelolaan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE pengelolaan (
  id $idType,
  activity $textType,
  date $textType,
  notes $textType
)
''');
  }

  Future<int> insert(PengelolaanItem item) async {
    final db = await instance.database;
    return await db.insert('pengelolaan', item.toMap());
  }

  Future<List<PengelolaanItem>> getAllPengelolaan() async {
    final db = await instance.database;
    final result = await db.query('pengelolaan', orderBy: 'date DESC');
    return result.map((json) => PengelolaanItem.fromMap(json)).toList();
  }

  Future<int> update(PengelolaanItem item) async {
    final db = await instance.database;
    return db.update(
      'pengelolaan',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'pengelolaan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}