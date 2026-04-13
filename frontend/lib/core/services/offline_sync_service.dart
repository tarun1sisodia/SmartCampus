import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class OfflineSyncService {
  static Database? _db;

  static Future<void> init() async {
    final path = await getDatabasesPath();
    _db = await openDatabase(
      join(path, 'attendance.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pending_attendance(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sessionId TEXT,
            studentId TEXT,
            status TEXT,
            remarks TEXT,
            timestamp TEXT,
            synced INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  static Future<void> addPendingAttendance(Map<String, dynamic> record) async {
    // Handling list vs map
    if (record['attendance'] != null && record['attendance'] is List) {
      final batch = _db!.batch();
      for (var student in record['attendance']) {
        batch.insert('pending_attendance', {
          'sessionId': record['sessionId'],
          'studentId': student['studentId'],
          'status': student['status'],
          'remarks': student['remarks'] ?? '',
          'timestamp': DateTime.now().toIso8601String(),
          'synced': 0,
        });
      }
      await batch.commit(noResult: true);
    } else {
      await _db?.insert('pending_attendance', {
        'sessionId': record['sessionId'],
        'studentId': record['studentId'],
        'status': record['status'],
        'remarks': record['remarks'] ?? '',
        'timestamp': DateTime.now().toIso8601String(),
        'synced': 0,
      });
    }
  }

  static Future<List<Map<String, dynamic>>> getUnsyncedRecords() async {
    return await _db?.query('pending_attendance', where: 'synced = 0') ?? [];
  }

  static Future<void> markSynced(int id) async {
    await _db?.update('pending_attendance', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteSyncedRecords() async {
    await _db?.delete('pending_attendance', where: 'synced = 1');
  }
}
