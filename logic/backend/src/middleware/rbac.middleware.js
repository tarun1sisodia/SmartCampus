// =============================================================
// rbac.middleware.js  ->  ALGORITHM ONLY (source: backend/src/middleware/rbac.middleware.js)
// =============================================================

// export default (...allowedRoles) => (req, res, next) :
//   req.user missing OR role not in allowedRoles -> 403 'Forbidden'
//   else next()
//   usage: rbac('super_admin', 'org_admin', 'teacher')
