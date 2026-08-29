// =============================================================
// Organisation.model.js  ->  ALGORITHM ONLY (source: backend/src/models/Organisation.model.js)
// =============================================================

// schema: name, type enum ['school','college'], domain (sparse unique), address,
//   contactEmail, contactPhone,
//   subscription { plan free|premium|enterprise, validUntil, maxTeachers 10, maxStudents 500 },
//   status enum ['active','suspended','trial'] default trial, createdBy
// index on status
