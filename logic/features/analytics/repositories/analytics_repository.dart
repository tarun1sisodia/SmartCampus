// =============================================================
// analytics_repository.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/features/analytics/repositories/analytics_repository.dart)
// =============================================================

// class AnalyticsRepository(ApiClient, HiveService) :

// fetchTeacherStats(teacherId, startDate, endDate) :
//   GET /analytics/teacher/<teacherId>?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD
//   parse data -> TeacherStatsModel
//   CACHE: store {timestamp(ms), data} json-encoded in cache_box under 'teacher_stats_<id>' (1h TTL)
//   non-200/error -> throw

// getCachedStats(teacherId) :
//   read 'teacher_stats_<id>' from cache box
//   decode; if older than 3600000 ms (1 hour) -> ignore (null)
//   else return the parsed model
