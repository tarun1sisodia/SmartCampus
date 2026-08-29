// =============================================================
// health.routes.js  ->  ALGORITHM ONLY (source: backend/src/routes/v1/health.routes.js)
// =============================================================

// GET /health :
//   mongo    = mongoose readyState == 1
//   redis    = client status 'ready'
//   cloudinary = env creds present
//   respond 200 { status:'ok', mongo, redis, cloudinary, uptime }  (no auth, skipped in access logs)
