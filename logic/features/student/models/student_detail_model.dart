// =============================================================
// student_detail_model.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/features/student/models/student_detail_model.dart)
// =============================================================

// class StudentDetailModel (Equatable) :
//   fields: id, name, rollNumber, photoUrl?, email?, contact?, parentContact?,
//           address?, enrollmentYear?, isActive, course?, semester?, section?

// fromJson -> normalize then map; _normalizeJson handles key variants:
//   id <- id|_id ; rollNumber <- rollNumber|roll_number ;
//   photoUrl <- photoUrl|photo|avatarUrl|image_url ;
//   enrollmentYear|parentContact <- camelCase|snake_case ; isActive <- isActive|is_active
//   course/semester/section <- <name>Name | object.name | plain value

// class StudentAttendanceSummary (Equatable) :
//   fields: presentCount, absentCount, lateCount
//   total = sum ; presentPercentage = present/total (0 when total 0)
//   fromJson with fallback keys present/absent/late, values coerced to int via _toInt
