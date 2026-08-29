// =============================================================
// backup.service.test.js  ->  ALGORITHM ONLY (source: backend/tests/unit/backup.service.test.js)
// =============================================================

// unit tests (child_process + s3 mocked):
//   createFullBackup -> runs mongodump with the uri as ARGV (no shell), uploads to s3,
//   record moves pending -> completed with size ; failure path marks 'failed'
