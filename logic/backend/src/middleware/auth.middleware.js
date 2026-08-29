// =============================================================
// auth.middleware.js  ->  ALGORITHM ONLY (source: backend/src/middleware/auth.middleware.js)
// =============================================================

// export default (req, res, next) :
//   read 'Authorization' header; must start with 'Bearer ' -> else 401 'No token provided'
//   verifyAccessToken(token) -> jwt.verify with the access secret
//   success -> req.user = { id: sub, role, organisation: org } ; next()
//   invalid/expired -> 401 'Invalid or expired token'
