import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import '../utils/platform_helper.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  factory AppDatabase() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (!PlatformHelper.isMobile) {
      debugPrint('⚠️ Non-mobile platform detected. Using in-memory SQLite (Dev mode).');
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      
      return await openDatabase(
        inMemoryDatabasePath,
        version: 3,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smart_campus.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pending_attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId TEXT NOT NULL,
        studentId TEXT NOT NULL,
        status TEXT NOT NULL,
        remarks TEXT,
        timestamp TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        retryCount INTEGER DEFAULT 0,
        nextRetryAt TEXT,
        lastError TEXT
      )
    ''');

    await db.execute(_createSessionCacheTableQuery);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS cached_sessions');
      await db.execute(_createSessionCacheTableQuery);
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE pending_attendance ADD COLUMN retryCount INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE pending_attendance ADD COLUMN nextRetryAt TEXT');
      await db.execute('ALTER TABLE pending_attendance ADD COLUMN lastError TEXT');
    }
  }

  static const String _createSessionCacheTableQuery = '''
      CREATE TABLE session_cache (
        cacheKey TEXT PRIMARY KEY,
        jsonData TEXT NOT NULL,
        expiresAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''';

  // Generic methods
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(String table, Map<String, dynamic> data, {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }
}
