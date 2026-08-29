// =============================================================
// session_repository.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/features/session/repositories/session_repository.dart)
// =============================================================

// class SessionRepository(ApiClient) :

// fetchSessionHistory(teacherId, startDate?, endDate?) :
//   default window: last 30 days ending now
//   GET /sessions?teacherId&startDate(YYYY-MM-DD)&endDate(YYYY-MM-DD)
//   unwrap data | sessions | payload -> map to SessionModel list; non-200 -> empty

// fetchSessionDetails(sessionId) :
//   GET /attendance/session/<sessionId> -> unwrap payload -> SessionDetailModel.fromJson
//   (subject info + every student's attendance record for that session)
