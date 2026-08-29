// =============================================================
// redis.js  ->  ALGORITHM ONLY (source: backend/src/config/redis.js)
// ioredis client with automatic failover between two endpoints.
// =============================================================

// urls = [REDIS_URL, REDIS_URL2] (second is the fallback)
// create client on urls[0] with maxRetriesPerRequest:null (queue, don't crash) + enableReadyCheck:false

// retryStrategy(times) :
//   after 3 failed retries AND more than one url configured:
//     switch to the NEXT endpoint (round-robin index)
//     rewrite client host/port (+ tls if rediss://) to the fallback URI
//     retry immediately (500ms)
//   otherwise retry with backoff times*100ms capped at 3s
// log connect + error events
