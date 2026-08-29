// =============================================================
// env.js  ->  ALGORITHM ONLY (source: backend/src/config/env.js)
// Loads .env / .env.<NODE_ENV> and fails fast on weak secrets.
// =============================================================

// load dotenv from backend root, file chosen by NODE_ENV (.env.development, .env.production...)

// validateEnv() (runs immediately on import):
//   secrets checked: JWT_ACCESS_SECRET (>= 32 chars), JWT_REFRESH_SECRET (>= 32), QR_SECRET_KEY (>= 24)
//   for each: missing / too short / equals a KNOWN insecure default ('changeme', 'secret', ...)
//     production -> collect as FATAL errors; development -> only warn and continue
//   production extra: warn if FRONTEND_URL missing or contains http:// origins
//   any fatal error -> log all + throw 'Invalid environment configuration' (app refuses to boot)
