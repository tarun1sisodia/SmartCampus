// =============================================================
// BackupRecord.model.js  ->  ALGORITHM ONLY (source: backend/src/models/BackupRecord.model.js)
// =============================================================

// schema: organisation (null = global), backupType full|incremental,
//   status pending|completed|failed, s3Key, sizeBytes, startedAt, completedAt, triggeredBy
// lifecycle: created 'pending' -> updated to completed/failed by the backup service
