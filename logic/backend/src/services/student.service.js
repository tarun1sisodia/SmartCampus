// =============================================================
// student.service.js  ->  ALGORITHM ONLY (source: backend/src/services/student.service.js)
// =============================================================

// scopedStudent(studentId, scope) : findOne with organisation filter unless super admin
//   -> 404 otherwise (IDOR guard: other-org ids look like 'not found')

// createStudent(fields, orgId) / getStudent(query) / updateStudent(query, fields) / softDeleteStudent
//   (soft delete = isActive:false; data is never removed)

// bulkImport(students[], orgId, requesterId) :  CSV import, ALL-OR-NOTHING
//   mongoose transaction:
//     per row: require rollNumber/name/course/semester/section else count as failed + reason
//     existing (org, rollNumber) -> update in place; else create — inside the session
//   commit -> publish 'students.imported' { succeeded, failed, errors }
//   any throw -> abortTransaction (no half-imported class)

// listStudents(filters, orgId, isSuperAdmin, page, limit) :
//   org pinned unless super; course/semester/section filters
//   search -> escapeRegExp then name OR rollNumber regex 'i' (user input can't become regex code)
//   parallel find + countDocuments, paginate, populate, sort rollNumber

// uploadPhoto/deletePhoto(studentId, ...) : scopedStudent check first (IDOR), cloudinary, save url
