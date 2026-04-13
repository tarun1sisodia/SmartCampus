import '../app_database.dart';

class SessionCacheDao {
  SessionCacheDao(this._db);

  final AppDatabase _db;
  static const String table = 'session_cache';

  Future<int> upsert({
    required String cacheKey,
    required String jsonData,
    required String expiresAtIso,
  }) {
    return _db.insert(table, {
      'cacheKey': cacheKey,
      'jsonData': jsonData,
      'expiresAt': expiresAtIso,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> getByKey(String cacheKey) async {
    final rows = await _db.query(
      table,
      where: 'cacheKey = ?',
      whereArgs: [cacheKey],
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first;
  }

  Future<int> deleteByKey(String cacheKey) {
    return _db.delete(table, where: 'cacheKey = ?', whereArgs: [cacheKey]);
  }

  Future<int> deleteExpired() {
    return _db.delete(
      table,
      where: 'expiresAt <= ?',
      whereArgs: [DateTime.now().toUtc().toIso8601String()],
    );
  }
}
