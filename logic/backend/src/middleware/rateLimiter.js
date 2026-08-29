// =============================================================
// rateLimiter.js  ->  ALGORITHM ONLY (source: backend/src/middleware/rateLimiter.js)
// express-rate-limit backed by Redis, keyed by IP, FAIL-OPEN.
// =============================================================

// makeStore() : RedisStore whose sendCommand:
//   if redis not in 'ready' state -> return a ZEROED reply shaped per command (fail open:
//     availability wins over limiting accuracy — requests keep flowing when redis is down)
//   try redis.call(...) ; on error -> also fail open
// build(windowMs, max, message) : limiter keyed by req.ip (trust proxy set in app.js), standard headers

// export 3 presets (all 15-minute windows):
//   strictLimiter    max 10  -> login / forgot / reset / qr verify (brute force guard)
//   sensitiveLimiter max 30  -> refresh / invite / change password
//   standardLimiter  max 300 -> default budget for the whole /api/v1
