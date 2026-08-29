// =============================================================
// teacher_stats_model.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/features/analytics/models/teacher_stats_model.dart)
// =============================================================

// class TeacherStatsModel : overallAttendance + subjectBreakdown[] + trend[]
// class SubjectStats      : subjectName + attendance%           (per-subject bars)
// class DailyStats        : date + attendance%                  (line chart points)
// fromJson -> direct mapping with 0/empty defaults; no logic beyond parsing
