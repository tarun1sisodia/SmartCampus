// =============================================================
// dailyBackup.job.js  ->  ALGORITHM ONLY (source: backend/src/jobs/dailyBackup.job.js)
// =============================================================

// setupDailyBackup() :
//   backupQueue.process('daily-backup') :
//     distributed lock: redis SETNX 'lock:daily-backup' -> not acquired = another worker runs it, skip
//     acquired -> lock expires in 2h; try createFullBackup(); finally release the lock
//   schedule the job with cron '0 2 * * *' (every day 02:00)
