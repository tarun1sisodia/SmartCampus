// =============================================================
// getAttendanceReport.query.js  ->  ALGORITHM ONLY (source: backend/src/cqrs/queries/getAttendanceReport.query.js)
// =============================================================

// handle(query { courseId?, semesterId?, sectionId?, organisationId, isSuperAdmin }) :
//   aggregate AttendanceSummary by student over the denormalised view:
//   presentCount counts ONLY 'present'; total = all rows -> per-student report rows
