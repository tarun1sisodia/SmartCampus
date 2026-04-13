import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  static Database? _database;

  factory LocalDbService() => _instance;

  LocalDbService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smart_campus_local.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    debugPrint('Creating local database schema...');

    // Table for cached classes (Dashboard)
    await db.execute('''
      CREATE TABLE classes (
        id TEXT PRIMARY KEY,
        teacher_id TEXT,
        subject_id TEXT,
        course_id TEXT,
        semester INTEGER,
        section TEXT,
        subject_name TEXT,
        course_name TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Table for cached students (Mark Attendance)
    await db.execute('''
      CREATE TABLE students (
        id TEXT PRIMARY KEY,
        name TEXT,
        roll_number TEXT,
        image_url TEXT,
        class_id TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Table for pending attendance records (Sync)
    await db.execute('''
      CREATE TABLE pending_attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT,
        student_id TEXT,
        status TEXT,
        remarks TEXT,
        created_at TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    debugPrint('Local database schema created successfully.');
  }

  // --- CRUD Operations for Classes ---

  Future<void> saveClasses(List<Map<String, dynamic>> classesJson) async {
    final db = await database;
    final batch = db.batch();
    for (var classJson in classesJson) {
      batch.insert('classes', classJson, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedClasses() async {
    final db = await database;
    return await db.query('classes', orderBy: 'created_at DESC');
  }

  // --- CRUD Operations for Students ---

  Future<void> saveStudents(List<Map<String, dynamic>> studentsJson) async {
    final db = await database;
    final batch = db.batch();
    for (var studentJson in studentsJson) {
      batch.insert('students', studentJson, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedStudents(String classId) async {
    final db = await database;
    return await db.query('students', where: 'class_id = ?', whereArgs: [classId]);
  }

  // --- Sync Operations for Attendance ---

  Future<void> queueAttendance(Map<String, dynamic> record) async {
    final db = await database;
    await db.insert('pending_attendance', {
      ...record,
      'created_at': DateTime.now().toIso8601String(),
      'synced': 0
    });
    debugPrint('Attendance queued locally for sync');
  }

  Future<List<Map<String, dynamic>>> getPendingAttendance() async {
    final db = await database;
    return await db.query('pending_attendance', where: 'synced = 0');
  }

  Future<void> markAsSynced(int localId) async {
    final db = await database;
    await db.update('pending_attendance', {'synced': 1}, where: 'id = ?', whereArgs: [localId]);
  }
}
