// =============================================================
// errorHandler.js  ->  ALGORITHM ONLY (source: backend/src/middleware/errorHandler.js)
// One global error handler for the whole API.
// =============================================================

// (err, req, res, next) :
//   status = err.status || 500
//   status >= 500 :
//     Sentry.captureException(err)
//     log full message + url + method + ip + requestId + stack server-side
//   response message:
//     5xx in production -> generic 'Internal Server Error' (never leak internals); dev -> err.message
//     4xx -> err.message or a standard phrase map (400..429)
//   respond { success:false, message, requestId, code }
