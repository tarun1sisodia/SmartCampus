// =============================================================
// attendanceSummary.view.js  ->  ALGORITHM ONLY
// (source: backend/src/cqrs/materializedViews/attendanceSummary.view.js)
// Keeps the denormalised AttendanceSummary in sync with Attendance writes.
// =============================================================

// refreshAttendanceSummary({ sessionId, studentId, newStatus }) :
//   load session + student (skip if either gone)
//   upsert the summary row keyed (session, student):
//     copy course/subject/semester/organisation/date from the session
//     status = newStatus ; studentName + rollNumber copied for fast reports
