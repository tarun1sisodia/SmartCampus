// =============================================================
// AttendanceSummary.model.js  ->  ALGORITHM ONLY
// (source: backend/src/models/AttendanceSummary.model.js)
// DENORMALISED read model (CQRS) rebuilt from Attendance events for fast analytics.
// =============================================================

// schema: student/session/course/subject/semester refs + organisation, date, status,
//   plus copied display fields studentName, rollNumber (avoid joins in reports)
// unique index { session, student } ; index { organisation, student, semester }
