// =============================================================
// attendance.routes.js  ->  ALGORITHM ONLY (source: backend/src/routes/v1/attendance.routes.js)
// =============================================================

// POST /sessions              auth + rbac(teacher,super) + orgScope + validate -> createSession
// GET  /sessions              auth + orgScope                    -> list (?date=today, ?month=YYYY-MM)
// GET  /sessions/month        auth + orgScope                    -> calendar month
// POST /mark                  auth + rbac(teacher,super) + validate(markAttendanceSchema) -> markBulk
// GET  /session/:sessionId    auth + orgScope                    -> attendance of one session
// GET  /student/:studentId    auth + orgScope                    -> student summary
// POST /sync                  auth + rbac(teacher)               -> offline sync upload
// GET  /qr/generate/:sessionId auth + rbac(teacher,super)        -> mint rolling token
// POST /qr/verify             auth + rbac(student) + strictLimiter -> verify scan + mark present
