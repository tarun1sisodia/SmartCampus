// =============================================================
// attendance_repository.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/features/attendance/repositories/attendance_repository.dart)
// =============================================================

// class AttendanceRepository(ApiClient) :

// fetchStudentsForSession(sessionId) :
//   GET /students?sessionId=...
//   unwrap list from data | students | payload itself -> map to AttendanceRecordModel list
//   non-200 -> empty list; error -> rethrow

// markAttendance(sessionId, records) :
//   POST /attendance/mark {sessionId, attendance: [...]}
//   attendance list = only records with status != 'pending', each {studentId, status, timestamp=now UTC}

// syncOffline(records) : POST /attendance/sync {records}   // bulk upload of the offline queue

// generateQrToken(sessionId) : GET /attendance/qr/generate/<sessionId> -> QrTokenResponse from data

// verifyQrToken(request) : POST /attendance/qr/verify with request.toJson()
