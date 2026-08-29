// =============================================================
// complete_setup_database.sql  ->  ALGORITHM ONLY (source: backend/complete_setup_database.sql)
// Reference SQL schema (the live DB is MongoDB/Mongoose — this documents the ERD).
// =============================================================

// CREATE TABLE IF NOT EXISTS for: users, subjects, courses, classes, students, class_students,
//   attendance_sessions, attendance_records, user_feedback, audit_logs (+ ~34 indexes)
// each table: primary key id, organisation_id tenant column, timestamps
// attendance_records: UNIQUE (session_id, student_id) — same rule the mongo index enforces
