// =============================================================
// updateAnalytics.subscriber.js  ->  ALGORITHM ONLY (source: backend/src/events/subscribers/updateAnalytics.subscriber.js)
// =============================================================

// setup() : on 'attendance.marked' :
//   dynamic import of the materialized view (avoids circular deps at boot)
//   -> refreshAttendanceSummary(event data)  // keeps analytics tables fresh
//   errors are logged, never thrown (don't break the emitter)
