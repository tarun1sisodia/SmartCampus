// =============================================================
// logger.js  ->  ALGORITHM ONLY (source: backend/src/config/logger.js)
// =============================================================

// winston logger:
//   level: info in production, debug otherwise
//   format: timestamp + error stack + json
//   file transports: logs/error.log (errors only) + logs/combined.log (everything)
//   + colorized console transport for dev visibility
