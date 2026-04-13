import '../app_database.dart';

class PendingAttendanceDao {
  final AppDatabase _db;
  static const String table = 'pending_attendance';

  PendingAttendanceDao(this._db);

  Future<int> insert(Map<String, dynamic> record) {
    return _db.insert(table, record);
  }

  Future<List<Map<String, dynamic>>> getUnsynced() {
    return _db.query(table, where: 'synced = ?', whereArgs: [0]);
  }

  Future<int> markAsSynced(int id) {
    return _db.update(table, {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) {
    return _db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
