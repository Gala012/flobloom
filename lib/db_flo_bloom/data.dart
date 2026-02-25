import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'db_flo_bloom_entity.dart';

class FloBloomDatabase {
  static final FloBloomDatabase _instance = FloBloomDatabase._internal();
  static Database? _database;
  factory FloBloomDatabase() {
    return _instance;
  }
  FloBloomDatabase._internal();
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'flo_bloom.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE flo_bloom_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_path TEXT NOT NULL,
        original_path TEXT NOT NULL,
        create_time INTEGER NOT NULL,
        file_size INTEGER NOT NULL,
        resolution TEXT NOT NULL,
        is_animated INTEGER NOT NULL DEFAULT 0,
        filter_name TEXT,
        stickers TEXT,
        effect_name TEXT,
        has_beauty INTEGER NOT NULL DEFAULT 0,
        has_crop INTEGER NOT NULL DEFAULT 0,
        has_frame INTEGER NOT NULL DEFAULT 0,
        has_watermark INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<int> insertRecord(FloBloomRecord record) async {
    final db = await database;
    return await db.insert(
      'flo_bloom_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FloBloomRecord>> getAllRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'flo_bloom_records',
      orderBy: 'create_time DESC',
    );
    return List.generate(maps.length, (i) {
      return FloBloomRecord.fromMap(maps[i]);
    });
  }

  Future<FloBloomRecord?> getRecordById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'flo_bloom_records',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return FloBloomRecord.fromMap(maps[0]);
  }

  Future<int> updateRecord(FloBloomRecord record) async {
    final db = await database;
    return await db.update(
      'flo_bloom_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteRecord(int id) async {
    final db = await database;
    return await db.delete(
      'flo_bloom_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllRecords() async {
    final db = await database;
    return await db.delete('flo_bloom_records');
  }

  Future<List<FloBloomRecord>> getRecordsByType(bool isAnimated) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'flo_bloom_records',
      where: 'is_animated = ?',
      whereArgs: [isAnimated ? 1 : 0],
      orderBy: 'create_time DESC',
    );
    return List.generate(maps.length, (i) {
      return FloBloomRecord.fromMap(maps[i]);
    });
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
