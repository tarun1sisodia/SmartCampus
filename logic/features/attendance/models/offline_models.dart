// =============================================================
// offline_models.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/features/attendance/models/offline_models.dart)
// =============================================================

// Plain data classes for the offline first flow (isSynced flags + createdAt/updatedAt):
//   OfflineClass        -> a class/session snapshot stored offline (teacher/subject/course/semester/section)
//   OfflineStudent      -> student cached for offline marking
//   OfflineAttendance   -> one attendance mark waiting to sync (status, remarks, timestamp, synced flag)
//   (each: fields + fromJson/toJson + copyWith — mapping only, no business logic)
