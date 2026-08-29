// =============================================================
// offline_sync_service.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/core/services/offline_sync_service.dart)
// Older standalone SQLite helper for the offline attendance queue.
// =============================================================

// class OfflineSyncService (all static) :
//   init() : open 'attendance.db' (version 1); on create -> make pending_attendance table
//            (id, sessionId, studentId, status, remarks, timestamp, synced=0)

//   addPendingAttendance(record) :
//     if record has an 'attendance' LIST -> insert one row per student in a single batch commit
//     else                               -> insert a single row
//     every row gets timestamp = now, synced = 0

//   getUnsyncedRecords() -> select rows where synced = 0
//   markSynced(id)       -> set synced = 1
//   deleteSyncedRecords()-> delete rows where synced = 1 (cleanup)
