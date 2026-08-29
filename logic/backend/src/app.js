// =============================================================
// app.js  ->  ALGORITHM ONLY (source: backend/src/app.js)
// Express app assembly: security, parsing, logging, routes, docs, errors.
// =============================================================

// build swagger docs from route files (openapi 3, bearer JWT security)

// app = express()
// app.set('trust proxy', 1)            -> real client IP behind load balancers (rate limiting)

// middleware pipeline (order matters):
//   helmet()                            -> security headers
//   cors({ credentials }) with dynamic origin check:
//     allowed = localhost:3000, localhost:3011 (dev portals) + FRONTEND_URL split by comma
//     no Origin (mobile app/curl) or allowed origin -> accept; otherwise silently reject
//   express.json + urlencoded, limit 1mb -> body parsing with a size cap
//   cookieParser                        -> read the httpOnly refresh-token cookie
//   morgan http logs (skip /health; in prod pipe through winston, format includes request id)
//   requestId middleware                -> attach X-Request-Id to every request

// routes:
//   /api/v1  -> global standardLimiter + all v1 routers
//   /api-docs -> swagger UI, ONLY when not production

// handlers:
//   unmatched route -> 404 json { success:false }
//   errorHandler    -> global error handler (last)
