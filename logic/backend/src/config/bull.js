// =============================================================
// bull.js  ->  ALGORITHM ONLY (source: backend/src/config/bull.js)
// Bull job queues on Redis for background work.
// =============================================================

// custom ioredis client for bull: maxRetriesPerRequest null, always reconnectOnError,
//   retry backoff times*100ms max 3s, give up after 10 tries

// createClient(type) factory -> bull reuses ONE client; subscriber/bclient get duplicates
// defaultJobOptions for every queue: 3 attempts, exponential backoff 1s,
//   removeOnComplete, 30s job timeout

// export queues: emailQueue, backupQueue, analyticsQueue
