// =============================================================
// attendance_record_model.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/features/attendance/models/attendance_record_model.dart)
// =============================================================

// class AttendanceRecordModel (Equatable) :
//   fields: studentId, name, rollNumber?, photoUrl?, status('present'|'absent'|'late'|'pending'), remarks?, timestamp?

// copyWith(status, remarks) -> clone with new status/remarks (used while marking in the carousel)

// fromJson(json) -> normalize then map fields, status default 'pending', parse timestamp

// _normalizeJson(json) : studentId <- studentId|student._id|student.id|id ;
//   name <- name|student.name ; rollNumber <- rollNumber|student.rollNumber|roll_number ;
//   photoUrl <- photoUrl|avatarUrl|photo|student.photo|student.avatar ;
//   timestamp <- timestamp|created_at|createdAt
