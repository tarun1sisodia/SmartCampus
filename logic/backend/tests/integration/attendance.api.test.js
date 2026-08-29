// =============================================================
// attendance.api.test.js  ->  ALGORITHM ONLY (source: backend/tests/integration/attendance.api.test.js)
// =============================================================

// integration tests:
//   POST /attendance/mark with valid jwt -> 200 { updatedCount } and service called with scoped args
//   invalid payload -> rejected by zod validation with 400
