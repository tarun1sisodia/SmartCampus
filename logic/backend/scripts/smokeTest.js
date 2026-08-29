// =============================================================
// smokeTest.js  ->  ALGORITHM ONLY (source: backend/scripts/smokeTest.js)
// =============================================================

// verifyExternalConnections() : used by server.js BEFORE boot:
//   check mongoose URI reachable, redis ping, S3 ListBuckets, cloudinary ping
//   -> log each dependency's state (warnings only, boot continues)
