// =============================================================
// session_detail_model.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/features/session/models/session_detail_model.dart)
// =============================================================

// class SessionDetailModel EXTENDS SessionModel :
//   adds attendanceRecords: List<AttendanceRecordModel>

// fromJson(json) :
//   parse the base SessionModel part
//   records list <- json['attendance'] else json['students'] (whichever exists)
//                 -> map each entry to AttendanceRecordModel
//   combine into SessionDetailModel
