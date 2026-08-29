// =============================================================
// app_database.dart  ->  ALGORITHM ONLY (source: frontend/lib/core/database/app_database.dart)
// SQLite (sqflite) singleton used mainly for OFFLINE attendance queue + session cache.
// =============================================================

// class AppDatabase :
//   singleton pattern: private constructor + factory returns the one instance; static _database cache

// database (getter) :
//   if already opened -> return it; else init and cache

// _initDatabase() :
//   if NOT mobile (web/desktop dev) -> init sqflite FFI and open an IN-MEMORY database (version 3)
//   else -> open file 'smart_campus.db' (version 4) with onCreate + onUpgrade hooks

// _onCreate(db, version) :
//   create pending_attendance table: id, sessionId, studentId, status, remarks, timestamp,
//                                    synced(0), retryCount(0), nextRetryAt, lastError
//   create session_cache table: cacheKey (PK), jsonData, expiresAt, updatedAt

// _onUpgrade(db, old, new) :
//   upgrade < 2 -> recreate cached_sessions as session_cache (schema changed)
//   upgrade < 3 -> ALTER pending_attendance ADD retryCount, nextRetryAt, lastError columns

// generic CRUD wrappers (all: get db then run sqflite call):
//   insert(table, data)  -> insert with ConflictAlgorithm.replace (acts as upsert)
//   query(table, where, whereArgs) -> filtered select
//   update / delete      -> filtered update / delete
//   transaction(action)  -> run actions atomically inside one txn
