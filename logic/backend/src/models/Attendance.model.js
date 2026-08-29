// =============================================================
// Attendance.model.js  ->  ALGORITHM ONLY (source: backend/src/models/Attendance.model.js)
// One student's status in one session (source of truth).
// =============================================================

// schema: session ref, student ref, status enum ['present','absent','late','excused'],
//   markedBy (user ref), markedVia enum ['manual','qr'] default manual, qrTokenUsed,
//   locationData { lat, lon }, remarks, organisation, timestamp default now
// UNIQUE index { session, student } -> one record per student per session (upserts rely on it)
// index { organisation, student }
