// =============================================================
// attendance_stats_model.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/features/attendance/models/attendance_stats_model.dart)
// =============================================================

// class AttendanceStatsModel :
//   fields: totalStudents, presentCount, absentCount, lateCount, excusedCount
//   unmarkedCount = total - (present+absent+late+excused)      // computed in constructor
//   percentage getters: each count / totalStudents * 100 (0 when total is 0)
//   fromJson -> simple int mapping with 0 defaults
