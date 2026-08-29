// =============================================================
// requestId.js  ->  ALGORITHM ONLY (source: backend/src/middleware/requestId.js)
// =============================================================

// (req, res, next) :
//   req.id = incoming 'x-request-id' header OR a new crypto UUID
//   echo it back as the response header X-Request-Id (log correlation)
