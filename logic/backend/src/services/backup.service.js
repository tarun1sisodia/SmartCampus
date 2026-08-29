// =============================================================
// backup.service.js  ->  ALGORITHM ONLY (source: backend/src/services/backup.service.js)
// mongodump -> gzip -> upload to S3/R2, tracked in BackupRecord.
// =============================================================

// createFullBackup(triggeredBy, orgId?) :
//   create BackupRecord status 'pending' + startedAt
//   execFile('mongodump', ['--archive=/tmp/backup_<ts>.gz','--gzip','--uri=<MONGO_URI>'], 10min timeout)
//     (execFile + argv, NOT a shell string -> no command injection)
//   uploadFile(backup bucket, 'backups/<file>') via s3Client
//   success -> record completed + s3Key + sizeBytes; unlink temp file; return record
//   failure -> record 'failed' + rethrow
