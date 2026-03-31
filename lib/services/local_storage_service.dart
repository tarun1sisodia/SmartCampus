import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../models/student_model.dart';
import '../models/attendance_record_model.dart';
import '../models/attendance_session_model.dart';
import '../models/user_model.dart';
import '../models/class_model.dart';
import '../models/course_model.dart';
import '../models/subject_model.dart';
import 'database_helper.dart';

class LocalStorageService extends GetxService {
  static final LocalStorageService _singleton = LocalStorageService._internal();

  factory LocalStorageService() {
    return _singleton;
  }

  LocalStorageService._internal();

  late SharedPreferences _prefs;
  late Database _database;
  bool _isInitialized = false;

  // Storage keys
  static const String _keyUserData = 'user_data';
  static const String _keySettings = 'app_settings';
  static const String _keyTheme = 'theme_mode';
  static const String _keyLanguage = 'language';
  static const String _keyBiometric = 'biometric_enabled';
  static const String _keyOnboarding = 'onboarding_completed';
  static const String _keyRememberUser = 'remember_user';
  static const String _keyUserEmail = 'user_email';
  static const String _legacyKeyUserPassword = 'user_password';
  static const String _legacyKeyOfflineData = 'offline_data';
  static const String _keyLastSync = 'last_sync';

  // Database info
  static const String _databaseName = 'smartcampus.db';
  static const int _databaseVersion = 3;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    try {
      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      await _clearLegacyPreferenceData();
      debugPrint('SharedPreferences initialized successfully');

      // Initialize SQLite Database only if supported
      if (DatabaseHelper.isSupported) {
        await _initializeDatabase();
        debugPrint('SQLite Database initialized successfully');
        
        // MIGRATION: Check for data in old smart_campus_local.db (Zero Data Loss)
        await _migrateFromOldDatabase();
      } else {
        debugPrint(
            'SQLite not supported on this platform, using SharedPreferences only');
      }

      _isInitialized = true;
      debugPrint('Local Storage Service initialized successfully');
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error initializing Local Storage Service: $e');
      // Don't rethrow - allow app to continue with limited functionality
      _isInitialized = true; // Mark as initialized to prevent retry loops
    }
  }

  // Add these methods to your LocalStorageService class

  Future<LocalStorageService> init() async {
    if (!_isInitialized) {
      await _initializeStorage();
    }
    return this;
  }

  Future<void> _clearLegacyPreferenceData() async {
    await _prefs.remove(_legacyKeyUserPassword);
    await _prefs.remove(_legacyKeyOfflineData);
  }

// Get unsynced records
  Future<List<Map<String, dynamic>>> getUnsyncedRecords(
      String tableName) async {
    try {
      return await getRecords(
        tableName,
        where: 'is_synced = ?',
        whereArgs: [0],
        orderBy: 'created_at ASC',
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error getting unsynced records from $tableName: $e');
      Get.snackbar('Error getting unsynced records from ', '$tableName: $e');
      return [];
    }
  }

// Mark record as synced
  Future<bool> markAsSynced(String tableName, String recordId) async {
    try {
      final result = await updateRecord(
        tableName,
        {
          'is_synced': 1,
          'updated_at': DateTime.now().toIso8601String(),
        },
        'id = ?',
        [recordId],
      );
      return result > 0;
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error marking record as synced in $tableName: $e');
      Get.snackbar('Error marking record as synced in', '$tableName: $e');
      return false;
    }
  }

// Mark multiple records as synced
  Future<bool> markMultipleAsSynced(
      String tableName, List<String> recordIds) async {
    try {
      final batch = _database.batch();
      for (final recordId in recordIds) {
        batch.update(
          tableName,
          {
            'is_synced': 1,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [recordId],
        );
      }
      await batch.commit();
      return true;
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error marking multiple records as synced in $tableName: $e');
      Get.snackbar(
          'Error marking multiple records as synced in', '$tableName: $e');
      return false;
    }
  }

// Get records that need conflict resolution
  Future<List<Map<String, dynamic>>> getConflictedRecords(
      String tableName) async {
    try {
      return await getRecords(
        tableName,
        where: 'is_synced = ? AND updated_at > ?',
        whereArgs: [
          1,
          DateTime.now().subtract(const Duration(hours: 1)).toIso8601String()
        ],
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error getting conflicted records from $tableName: $e');
      Get.snackbar('Error getting conflicted records from', '$tableName: $e');
      return [];
    }
  }

// Clear all unsynced data (for testing purposes)
  Future<bool> clearUnsyncedData() async {
    try {
      final tables = [
        'classes',
        'students',
        'attendance_sessions',
        'attendance_records'
      ];

      for (final table in tables) {
        await _database.delete(table, where: 'is_synced = ?', whereArgs: [0]);
      }

      // Clear sync queue
      await _database.delete('sync_queue');

      return true;
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error clearing unsynced data: $e');
      Get.snackbar('Error clearing unsynced data', '$e');
      return false;
    }
  }

// Get sync statistics
  Future<Map<String, int>> getSyncStats() async {
    try {
      final stats = <String, int>{};
      final tables = [
        'classes',
        'students',
        'attendance_sessions',
        'attendance_records'
      ];

      for (final table in tables) {
        final unsynced =
            await getRecords(table, where: 'is_synced = ?', whereArgs: [0]);
        stats['unsynced_$table'] = unsynced.length;

        final synced =
            await getRecords(table, where: 'is_synced = ?', whereArgs: [1]);
        stats['synced_$table'] = synced.length;
      }

      final queueItems = await getRecords('sync_queue');
      stats['queue_items'] = queueItems.length;

      return stats;
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error getting sync stats: $e');
      return {};
    }
  }

// Delete synced records older than specified days (cleanup)
  Future<bool> cleanupOldSyncedRecords({int daysOld = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final tables = [
        'classes',
        'students',
        'attendance_sessions',
        'attendance_records'
      ];

      for (final table in tables) {
        await _database.delete(
          table,
          where: 'is_synced = ? AND updated_at < ?',
          whereArgs: [1, cutoffDate.toIso8601String()],
        );
      }

      return true;
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error cleaning up old synced records: $e');
      return false;
    }
  }

// Force mark record as unsynced (for retry)
  Future<bool> markAsUnsynced(String tableName, String recordId) async {
    try {
      final result = await updateRecord(
        tableName,
        {
          'is_synced': 0,
          'updated_at': DateTime.now().toIso8601String(),
        },
        'id = ?',
        [recordId],
      );
      return result > 0;
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error marking record as unsynced in $tableName: $e');
      return false;
    }
  }

// Check if record exists
  Future<bool> recordExists(String tableName, String recordId) async {
    try {
      final records = await getRecords(
        tableName,
        where: 'id = ?',
        whereArgs: [recordId],
        limit: 1,
      );
      return records.isNotEmpty;
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error checking if record exists in $tableName: $e');
      return false;
    }
  }

// Get record by ID
  Future<Map<String, dynamic>?> getRecordById(
      String tableName, String recordId) async {
    try {
      final records = await getRecords(
        tableName,
        where: 'id = ?',
        whereArgs: [recordId],
        limit: 1,
      );
      return records.isNotEmpty ? records.first : null;
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error getting record by ID from $tableName: $e');
      return null;
    }
  }

// Upsert record (insert or update)
  Future<bool> upsertRecord(String tableName, Map<String, dynamic> data) async {
    try {
      final recordId = data['id'];
      if (recordId == null) return false;

      final exists = await recordExists(tableName, recordId);

      if (exists) {
        final result =
            await updateRecord(tableName, data, 'id = ?', [recordId]);
        return result > 0;
      } else {
        final result = await insertRecord(tableName, data);
        return result > 0;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error upserting record in $tableName: $e');
      return false;
    }
  }

  Future<void> _initializeDatabase() async {
    try {
      if (!DatabaseHelper.isSupported) {
        debugPrint('Database not supported on this platform');
        return;
      }

      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, _databaseName);

      _database = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      );

      debugPrint('Database opened at: $path');
    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  // Check if database is available
  bool get isDatabaseAvailable => _isInitialized && DatabaseHelper.isSupported;

  /* Future<void> _createDatabase(Database db, int version) async {
    // Create tables for offline data storage
    await db.execute('''
      CREATE TABLE classes (
        id TEXT PRIMARY KEY,
        subject_name TEXT,
        course_name TEXT,
        semester INTEGER,
        section TEXT,
        teacher_id TEXT,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE students (
        id TEXT PRIMARY KEY,
        name TEXT,
        roll_number TEXT,
        email TEXT,
        phone TEXT,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance_sessions (
        id TEXT PRIMARY KEY,
        class_id TEXT,
        date TEXT,
        start_time TEXT,
        end_time TEXT,
        status TEXT,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 0,
        FOREIGN KEY (class_id) REFERENCES classes (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance_records (
        id TEXT PRIMARY KEY,
        session_id TEXT,
        student_id TEXT,
        status TEXT,
        marked_at TEXT,
        notes TEXT,
        is_synced INTEGER DEFAULT 0,
        FOREIGN KEY (session_id) REFERENCES attendance_sessions (id),
        FOREIGN KEY (student_id) REFERENCES students (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT,
        record_id TEXT,
        action TEXT,
        data TEXT,
        created_at TEXT
      )
    ''');
  }*/

  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    debugPrint('Upgrading database from version $oldVersion to $newVersion');
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE students ADD COLUMN class_id TEXT');
        debugPrint('Added class_id column to students table');
      } catch (e) {
        debugPrint('Migration error (version 2): $e');
      }
    }
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE attendance_sessions ADD COLUMN subject_name TEXT');
        await db.execute('ALTER TABLE attendance_sessions ADD COLUMN course_name TEXT');
        await db.execute('ALTER TABLE attendance_sessions ADD COLUMN semester INTEGER');
        await db.execute('ALTER TABLE attendance_sessions ADD COLUMN section TEXT');
        await db.execute('ALTER TABLE attendance_sessions ADD COLUMN closed_at TEXT');
        debugPrint('Added migration for denormalized attendance_sessions columns');
      } catch (e) {
        debugPrint('Migration error (version 3): $e');
      }
    }
  }

  // ==================== SharedPreferences Methods ====================

  // User Data
  Future<bool> saveUserData(Map<String, dynamic> userData) async {
    try {
      final jsonString = jsonEncode(userData);
      return await _prefs.setString(_keyUserData, jsonString);
    } catch (e) {
      debugPrint('Error saving user data: $e');
      return false;
    }
  }

  Map<String, dynamic>? getUserData() {
    try {
      final jsonString = _prefs.getString(_keyUserData);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  // App Settings
  Future<bool> saveAppSettings(Map<String, dynamic> settings) async {
    try {
      final jsonString = jsonEncode(settings);
      return await _prefs.setString(_keySettings, jsonString);
    } catch (e) {
      debugPrint('Error saving app settings: $e');
      return false;
    }
  }

  Map<String, dynamic> getAppSettings() {
    try {
      final jsonString = _prefs.getString(_keySettings);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      debugPrint('Error getting app settings: $e');
      return {};
    }
  }

  // Theme
  Future<bool> saveThemeMode(String themeMode) async {
    return await _prefs.setString(_keyTheme, themeMode);
  }

  String getThemeMode() {
    return _prefs.getString(_keyTheme) ?? 'system';
  }

  // Language
  Future<bool> saveLanguage(String languageCode) async {
    return await _prefs.setString(_keyLanguage, languageCode);
  }

  String getLanguage() {
    return _prefs.getString(_keyLanguage) ?? 'en';
  }

  // Biometric Settings
  Future<bool> saveBiometricEnabled(bool enabled) async {
    return await _prefs.setBool(_keyBiometric, enabled);
  }

  bool getBiometricEnabled() {
    return _prefs.getBool(_keyBiometric) ?? false;
  }

  // Onboarding
  Future<bool> saveOnboardingCompleted(bool completed) async {
    return await _prefs.setBool(_keyOnboarding, completed);
  }

  bool getOnboardingCompleted() {
    return _prefs.getBool(_keyOnboarding) ?? false;
  }

  // Remember User
  Future<bool> saveRememberUser(bool remember) async {
    return await _prefs.setBool(_keyRememberUser, remember);
  }

  bool getRememberUser() {
    return _prefs.getBool(_keyRememberUser) ?? false;
  }

  // User Credentials (for remember me functionality)
  Future<bool> saveUserCredentials(String email) async {
    try {
      await _prefs.setString(_keyUserEmail, email);
      return true;
    } catch (e) {
      debugPrint('Error saving user credentials: $e');
      return false;
    }
  }

  Map<String, String?> getUserCredentials() {
    return {
      'email': _prefs.getString(_keyUserEmail),
    };
  }

  Future<bool> clearUserCredentials() async {
    try {
      await _prefs.remove(_keyUserEmail);
      return true;
    } catch (e) {
      debugPrint('Error clearing user credentials: $e');
      return false;
    }
  }

  // Last Sync Time
  Future<bool> saveLastSyncTime(DateTime syncTime) async {
    return await _prefs.setString(_keyLastSync, syncTime.toIso8601String());
  }

  DateTime? getLastSyncTime() {
    final syncTimeString = _prefs.getString(_keyLastSync);
    if (syncTimeString != null) {
      return DateTime.parse(syncTimeString);
    }
    return null;
  }

  // ==================== SQLite Database Methods ====================

  // Generic database operations
  Future<int> insertRecord(
    String table,
    Map<String, dynamic> data, {
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) async {
    try {
      return await _database.insert(table, data, conflictAlgorithm: conflictAlgorithm);
    } catch (e) {
      debugPrint('Error inserting record into $table: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getRecord(
      String table, String where, List<dynamic> whereArgs) async {
    try {
      final results = await getRecords(
        table,
        where: where,
        whereArgs: whereArgs,
        limit: 1,
      );
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      debugPrint('Error getting single record from $table: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getRecords(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    try {
      return await _database.query(
        table,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit,
      );
    } catch (e) {
      debugPrint('Error getting records from $table: $e');
      return [];
    }
  }

  Future<int> updateRecord(
    String table,
    Map<String, dynamic> data,
    String where,
    List<dynamic> whereArgs,
  ) async {
    try {
      return await _database.update(table, data,
          where: where, whereArgs: whereArgs);
    } catch (e) {
      debugPrint('Error updating record in $table: $e');
      return 0;
    }
  }

  Future<int> deleteRecord(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    try {
      return await _database.delete(table, where: where, whereArgs: whereArgs);
    } catch (e) {
      debugPrint('Error deleting record from $table: $e');
      return 0;
    }
  }

  // Offline Classes
  /*Future<bool> saveClassOffline(Map<String, dynamic> classData) async {
    try {
      classData['is_synced'] = 0;
      await insertRecord('classes', classData);
      return true;
    } catch (e) {
      debugPrint('Error saving class offline: $e');
      return false;
    }
  }*/

  /* Future<List<Map<String, dynamic>>> getOfflineClasses() async {
    return await getRecords('classes', orderBy: 'created_at DESC');
  }
*/
  // Offline Students
  /* Future<bool> saveStudentOffline(Map<String, dynamic> studentData) async {
    try {
      studentData['is_synced'] = 0;
      await insertRecord('students', studentData);
      return true;
    } catch (e) {
      debugPrint('Error saving student offline: $e');
      return false;
    }
  }
*/
  /* Future<List<Map<String, dynamic>>> getOfflineStudents() async {
    return await getRecords('students', orderBy: 'created_at DESC');
  }*/

  // Offline Attendance
  /* Future<bool> saveAttendanceSessionOffline(
      Map<String, dynamic> sessionData) async {
    try {
      sessionData['is_synced'] = 0;
      await insertRecord('attendance_sessions', sessionData);
      return true;
    } catch (e) {
      debugPrint('Error saving attendance session offline: $e');
      return false;
    }
  }
*/
  /*Future<bool> saveAttendanceRecordOffline(
      Map<String, dynamic> recordData) async {
    try {
      recordData['is_synced'] = 0;
      await insertRecord('attendance_records', recordData);
      return true;
    } catch (e) {
      debugPrint('Error saving attendance record offline: $e');
      return false;
    }
  }
*/
  // Sync Queue Management
  Future<bool> addToSyncQueue(String tableName, String recordId, String action,
      Map<String, dynamic> data) async {
    try {
      await insertRecord('sync_queue', {
        'table_name': tableName,
        'record_id': recordId,
        'action': action,
        'data': jsonEncode(data),
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Error adding to sync queue: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    return await getRecords('sync_queue', orderBy: 'created_at ASC');
  }

  Future<bool> removeSyncQueueItem(int id) async {
    try {
      await deleteRecord('sync_queue', 'id = ?', [id]);
      return true;
    } catch (e) {
      debugPrint('Error removing sync queue item: $e');
      return false;
    }
  }

  // ==================== Utility Methods ====================

  // Get cache size
  Future<double> getCacheSize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = Directory(tempDir.path);

      if (await cacheDir.exists()) {
        int totalSize = 0;
        await for (final entity in cacheDir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
        return totalSize / (1024 * 1024); // Convert to MB
      }
      return 0.0;
    } catch (e) {
      debugPrint('Error calculating cache size: $e');
      return 0.0;
    }
  }

  // Clear cache
  Future<bool> clearCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = Directory(tempDir.path);

      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create();
      }
      return true;
    } catch (e) {
      debugPrint('Error clearing cache: $e');
      return false;
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Users table (for offline caching)
    await db.execute('''
    CREATE TABLE users (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT NOT NULL,
      phone TEXT,
      profile_image_url TEXT,
      role TEXT DEFAULT 'teacher',
      created_at TEXT,
      updated_at TEXT,
      is_synced INTEGER DEFAULT 0
    )
  ''');

    // Subjects table
    await db.execute('''
    CREATE TABLE subjects (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      code TEXT,
      created_at TEXT,
      updated_at TEXT,
      is_synced INTEGER DEFAULT 0
    )
  ''');

    // Courses table
    await db.execute('''
    CREATE TABLE courses (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      code TEXT,
      created_at TEXT,
      updated_at TEXT,
      is_synced INTEGER DEFAULT 0
    )
  ''');

    // Classes table (matches your Supabase schema)
    await db.execute('''
    CREATE TABLE classes (
      id TEXT PRIMARY KEY,
      teacher_id TEXT NOT NULL,
      subject_id TEXT NOT NULL,
      course_id TEXT NOT NULL,
      semester INTEGER NOT NULL,
      section TEXT,
      subject_name TEXT,
      course_name TEXT,
      created_at TEXT,
      updated_at TEXT,
      is_synced INTEGER DEFAULT 0,
      FOREIGN KEY (teacher_id) REFERENCES users (id),
      FOREIGN KEY (subject_id) REFERENCES subjects (id),
      FOREIGN KEY (course_id) REFERENCES courses (id)
    )
  ''');

    // Students table (matches your Supabase schema)
    await db.execute('''
    CREATE TABLE students (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      roll_number TEXT NOT NULL UNIQUE,
      class_id TEXT,
      image_url TEXT,
      created_at TEXT,
      updated_at TEXT,
      is_synced INTEGER DEFAULT 0

    )
  ''');

    // Class-Student relationship table
    await db.execute('''
    CREATE TABLE class_students (
      id TEXT PRIMARY KEY,
      class_id TEXT NOT NULL,
      student_id TEXT NOT NULL,
      created_at TEXT,
      is_synced INTEGER DEFAULT 0,
      FOREIGN KEY (class_id) REFERENCES classes (id),
      FOREIGN KEY (student_id) REFERENCES students (id),
      UNIQUE(class_id, student_id)
    )
  ''');

    // Attendance Sessions table (matches your Supabase schema)
    await db.execute('''
    CREATE TABLE attendance_sessions (
      id TEXT PRIMARY KEY,
      class_id TEXT NOT NULL,
      date TEXT NOT NULL,
      start_time TEXT,
      end_time TEXT,
      status TEXT DEFAULT 'open',
      created_by TEXT NOT NULL,
      subject_name TEXT,
      course_name TEXT,
      semester INTEGER,
      section TEXT,
      closed_at TEXT,
      created_at TEXT,
      updated_at TEXT,
      is_synced INTEGER DEFAULT 0,
      FOREIGN KEY (class_id) REFERENCES classes (id),
      FOREIGN KEY (created_by) REFERENCES users (id),
      UNIQUE(class_id, date)
    )
  ''');

    // Attendance Records table (matches your Supabase schema)
    await db.execute('''
    CREATE TABLE attendance_records (
      id TEXT PRIMARY KEY,
      session_id TEXT NOT NULL,
      student_id TEXT NOT NULL,
      status TEXT NOT NULL CHECK (status IN ('present', 'absent', 'late', 'excused')),
      remarks TEXT,
      created_at TEXT,
      updated_at TEXT,
      is_synced INTEGER DEFAULT 0,
      FOREIGN KEY (session_id) REFERENCES attendance_sessions (id),
      FOREIGN KEY (student_id) REFERENCES students (id),
      UNIQUE(session_id, student_id)
    )
  ''');

    // User Feedback table
    await db.execute('''
    CREATE TABLE user_feedback (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT,
      user_email TEXT,
      rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
      feedback TEXT,
      created_at TEXT,
      is_synced INTEGER DEFAULT 0,
      FOREIGN KEY (user_id) REFERENCES users (id)
    )
  ''');

    // Sync queue for offline operations
    await db.execute('''
    CREATE TABLE sync_queue (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      table_name TEXT NOT NULL,
      record_id TEXT NOT NULL,
      action TEXT NOT NULL,
      data TEXT NOT NULL,
      created_at TEXT NOT NULL,
      retry_count INTEGER DEFAULT 0
    )
  ''');

    // App metadata table
    await db.execute('''
    CREATE TABLE app_metadata (
      key TEXT PRIMARY KEY,
      value TEXT,
      updated_at TEXT
    )
  ''');
  }

// ==================== Model-specific Methods ====================

// User Model Methods
  Future<bool> saveUserOffline(UserModel user) async {
    try {
      final userData = user.toMap();
      userData['is_synced'] = 0;
      await insertRecord('users', userData);
      return true;
    } catch (e) {
      debugPrint('Error saving user offline: $e');
      return false;
    }
  }

  Future<UserModel?> getOfflineUser(String userId) async {
    try {
      final records =
          await getRecords('users', where: 'id = ?', whereArgs: [userId]);
      if (records.isNotEmpty) {
        return UserModel.fromMap(records.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting offline user: $e');
      return null;
    }
  }

// Class Model Methods
  Future<bool> saveClassOffline(ClassModel classModel) async {
    try {
      final classData = classModel.toJson();
      classData['is_synced'] = 0;
      await insertRecord('classes', classData);
      return true;
    } catch (e) {
      debugPrint('Error saving class offline: $e');
      return false;
    }
  }

  Future<List<ClassModel>> getOfflineClasses({String? teacherId}) async {
    try {
      List<Map<String, dynamic>> records;
      if (teacherId != null) {
        records = await getRecords('classes',
            where: 'teacher_id = ?',
            whereArgs: [teacherId],
            orderBy: 'created_at DESC');
      } else {
        records = await getRecords('classes', orderBy: 'created_at DESC');
      }

      return records.map((record) => ClassModel.fromJson(record)).toList();
    } catch (e) {
      debugPrint('Error getting offline classes: $e');
      return [];
    }
  }

  Future<bool> updateClassOffline(ClassModel classModel) async {
    try {
      final classData = classModel.toJson();
      classData['is_synced'] = 0;
      classData['updated_at'] = DateTime.now().toIso8601String();

      await updateRecord('classes', classData, 'id = ?', [classModel.id]);
      return true;
    } catch (e) {
      debugPrint('Error updating class offline: $e');
      return false;
    }
  }

// Student Model Methods
  Future<bool> saveStudentOffline(StudentModel student) async {
    try {
      final studentData = student.toJson();
      studentData['is_synced'] = 0;
      await insertRecord('students', studentData);
      return true;
    } catch (e) {
      debugPrint('Error saving student offline: $e');
      return false;
    }
  }

  Future<List<StudentModel>> getOfflineStudents({String? classId}) async {
    try {
      List<Map<String, dynamic>> records;

      if (classId != null) {
        // Get students for a specific class
        records = await _database.rawQuery('''
        SELECT s.* FROM students s
        INNER JOIN class_students cs ON s.id = cs.student_id
        WHERE cs.class_id = ?
        ORDER BY s.roll_number
      ''', [classId]);
      } else {
        records = await getRecords('students', orderBy: 'roll_number');
      }

      return records.map((record) => StudentModel.fromJson(record)).toList();
    } catch (e) {
      debugPrint('Error getting offline students: $e');
      return [];
    }
  }

  Future<bool> updateStudentOffline(StudentModel student) async {
    try {
      final studentData = student.toJson();
      studentData['is_synced'] = 0;
      studentData['updated_at'] = DateTime.now().toIso8601String();

      await updateRecord('students', studentData, 'id = ?', [student.id]);
      return true;
    } catch (e) {
      debugPrint('Error updating student offline: $e');
      return false;
    }
  }

// Course Model Methods
  Future<bool> saveCourseOffline(CourseModel course) async {
    try {
      final courseData = course.toJson();
      courseData['is_synced'] = 0;
      await insertRecord('courses', courseData);
      return true;
    } catch (e) {
      debugPrint('Error saving course offline: $e');
      return false;
    }
  }

  Future<List<CourseModel>> getOfflineCourses() async {
    try {
      final records = await getRecords('courses', orderBy: 'name');
      return records.map((record) => CourseModel.fromJson(record)).toList();
    } catch (e) {
      debugPrint('Error getting offline courses: $e');
      return [];
    }
  }

// Subject Model Methods
  Future<bool> saveSubjectOffline(SubjectModel subject) async {
    try {
      final subjectData = subject.toJson();
      subjectData['is_synced'] = 0;
      await insertRecord('subjects', subjectData);
      return true;
    } catch (e) {
      debugPrint('Error saving subject offline: $e');
      return false;
    }
  }

  Future<List<SubjectModel>> getOfflineSubjects() async {
    try {
      final records = await getRecords('subjects', orderBy: 'name');
      return records.map((record) => SubjectModel.fromJson(record)).toList();
    } catch (e) {
      debugPrint('Error getting offline subjects: $e');
      return [];
    }
  }

// Attendance Session Model Methods
  Future<bool> saveAttendanceSessionOffline(
      AttendanceSessionModel session) async {
    try {
      final sessionData = session.toJson();
      sessionData['is_synced'] = 0;
      await insertRecord('attendance_sessions', sessionData);
      return true;
    } catch (e) {
      debugPrint('Error saving attendance session offline: $e');
      return false;
    }
  }

  Future<List<AttendanceSessionModel>> getOfflineAttendanceSessions({
    String? classId,
    DateTime? date,
  }) async {
    try {
      String? where;
      List<dynamic>? whereArgs;

      if (classId != null && date != null) {
        where = 'class_id = ? AND date = ?';
        whereArgs = [classId, date.toIso8601String().split('T')[0]];
      } else if (classId != null) {
        where = 'class_id = ?';
        whereArgs = [classId];
      } else if (date != null) {
        where = 'date = ?';
        whereArgs = [date.toIso8601String().split('T')[0]];
      }

      final records = await getRecords(
        'attendance_sessions',
        where: where,
        whereArgs: whereArgs,
        orderBy: 'date DESC, created_at DESC',
      );

      return records
          .map((record) => AttendanceSessionModel.fromJson(record))
          .toList();
    } catch (e) {
      debugPrint('Error getting offline attendance sessions: $e');
      return [];
    }
  }

  Future<bool> updateAttendanceSessionOffline(
      AttendanceSessionModel session) async {
    try {
      final sessionData = session.toJson();
      sessionData['is_synced'] = 0;
      sessionData['updated_at'] = DateTime.now().toIso8601String();

      await updateRecord(
          'attendance_sessions', sessionData, 'id = ?', [session.id]);
      return true;
    } catch (e) {
      debugPrint('Error updating attendance session offline: $e');
      return false;
    }
  }

// Attendance Record Model Methods
  Future<bool> saveAttendanceRecordOffline(AttendanceRecordModel record) async {
    try {
      final recordData = record.toJson();
      recordData['is_synced'] = 0;
      await insertRecord('attendance_records', recordData);
      return true;
    } catch (e) {
      debugPrint('Error saving attendance record offline: $e');
      return false;
    }
  }

  Future<List<AttendanceRecordModel>> getOfflineAttendanceRecords({
    String? sessionId,
    String? studentId,
  }) async {
    try {
      String? where;
      List<dynamic>? whereArgs;

      if (sessionId != null && studentId != null) {
        where = 'session_id = ? AND student_id = ?';
        whereArgs = [sessionId, studentId];
      } else if (sessionId != null) {
        where = 'session_id = ?';
        whereArgs = [sessionId];
      } else if (studentId != null) {
        where = 'student_id = ?';
        whereArgs = [studentId];
      }

      final records = await getRecords(
        'attendance_records',
        where: where,
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
      );

      return records
          .map((record) => AttendanceRecordModel.fromJson(record))
          .toList();
    } catch (e) {
      debugPrint('Error getting offline attendance records: $e');
      return [];
    }
  }

  Future<bool> updateAttendanceRecordOffline(
      AttendanceRecordModel record) async {
    try {
      final recordData = record.toJson();
      recordData['is_synced'] = 0;
      recordData['updated_at'] = DateTime.now().toIso8601String();

      await updateRecord(
          'attendance_records', recordData, 'id = ?', [record.id]);
      return true;
    } catch (e) {
      debugPrint('Error updating attendance record offline: $e');
      return false;
    }
  }

// Class-Student relationship methods
  Future<bool> addStudentToClassOffline(
      String classId, String studentId) async {
    try {
      await insertRecord('class_students', {
        'id':
            '${classId}_${studentId}_${DateTime.now().millisecondsSinceEpoch}',
        'class_id': classId,
        'student_id': studentId,
        'created_at': DateTime.now().toIso8601String(),
        'is_synced': 0,
      });
      return true;
    } catch (e) {
      debugPrint('Error adding student to class offline: $e');
      return false;
    }
  }

  Future<bool> removeStudentFromClassOffline(
      String classId, String studentId) async {
    try {
      await deleteRecord('class_students', 'class_id = ? AND student_id = ?',
          [classId, studentId]);
      return true;
    } catch (e) {
      debugPrint('Error removing student from class offline: $e');
      return false;
    }
  }

// Bulk operations for better performance
  Future<bool> saveMultipleStudentsOffline(List<StudentModel> students) async {
    try {
      final batch = _database.batch();
      for (final student in students) {
        final studentData = student.toJson();
        studentData['is_synced'] = 0;
        batch.insert('students', studentData, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error saving multiple students offline: $e');
      return false;
    }
  }

  Future<bool> saveMultipleAttendanceRecordsOffline(
      List<AttendanceRecordModel> records) async {
    try {
      final batch = _database.batch();
      for (final record in records) {
        final recordData = record.toJson();
        recordData['is_synced'] = 0;
        batch.insert('attendance_records', recordData, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error saving multiple attendance records offline: $e');
      return false;
    }
  }

// Get statistics from offline data
  Future<Map<String, dynamic>> getOfflineAttendanceStats(String classId) async {
    try {
      final result = await _database.rawQuery('''
      SELECT 
        COUNT(DISTINCT ar.session_id) as total_sessions,
        COUNT(CASE WHEN ar.status = 'present' THEN 1 END) as total_present,
        COUNT(CASE WHEN ar.status = 'absent' THEN 1 END) as total_absent,
        COUNT(CASE WHEN ar.status = 'late' THEN 1 END) as total_late,
        COUNT(CASE WHEN ar.status = 'excused' THEN 1 END) as total_excused,
        COUNT(ar.id) as total_records
      FROM attendance_records ar
      INNER JOIN attendance_sessions ats ON ar.session_id = ats.id
      WHERE ats.class_id = ?
    ''', [classId]);

      if (result.isNotEmpty) {
        final stats = result.first;
        final totalRecords = stats['total_records'] as int;
        final totalPresent = stats['total_present'] as int;

        return {
          'total_sessions': stats['total_sessions'],
          'total_present': totalPresent,
          'total_absent': stats['total_absent'],
          'total_late': stats['total_late'],
          'total_excused': stats['total_excused'],
          'attendance_percentage':
              totalRecords > 0 ? (totalPresent / totalRecords) * 100 : 0.0,
        };
      }

      return {
        'total_sessions': 0,
        'total_present': 0,
        'total_absent': 0,
        'total_late': 0,
        'total_excused': 0,
        'attendance_percentage': 0.0,
      };
    } catch (e) {
      debugPrint('Error getting offline attendance stats: $e');
      return {};
    }
  }

  // ==================== Migration & Sync Helpers ====================

  Future<void> _migrateFromOldDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final oldDbPath = join(dbPath, 'smart_campus_local.db');
      
      if (!await File(oldDbPath).exists()) return;

      debugPrint('Found old database at $oldDbPath. Starting migration...');
      final oldDb = await openDatabase(oldDbPath);
      
      // Migrate pending_attendance
      final List<Map<String, dynamic>> pending = await oldDb.query('pending_attendance', where: 'synced = 0');
      
      if (pending.isNotEmpty) {
        debugPrint('Migrating ${pending.length} unsynced attendance records...');
        final batch = _database.batch();
        for (var record in pending) {
          // Map old schema to new schema
          batch.insert('attendance_records', {
            'id': 'migrate_${DateTime.now().millisecondsSinceEpoch}_${record['student_id']}',
            'session_id': record['session_id'],
            'student_id': record['student_id'],
            'status': record['status'],
            'remarks': record['remarks'],
            'created_at': record['created_at'],
            'updated_at': DateTime.now().toIso8601String(),
            'is_synced': 0,
          });
        }
        await batch.commit();
      }

      await oldDb.close();
      // Rename old database to prevent re-migration
      await File(oldDbPath).rename(join(dbPath, 'smart_campus_local.db.migrated'));
      debugPrint('Migration from old database successfully completed.');
    } catch (e) {
      debugPrint('Migration error: $e');
      // Non-critical: allow app to continue
    }
  }
}
