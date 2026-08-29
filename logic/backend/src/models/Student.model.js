// =============================================================
// Student.model.js  ->  ALGORITHM ONLY (source: backend/src/models/Student.model.js)
// =============================================================

// schema: rollNumber, name, email?, photo?, course/semester/section refs, organisation,
//   enrollmentYear, contact, parentContact, address, isActive default true (soft delete)
// UNIQUE index { organisation, rollNumber } -> roll numbers unique per org only
// index { organisation, course }
