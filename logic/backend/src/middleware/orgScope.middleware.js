// =============================================================
// orgScope.middleware.js  ->  ALGORITHM ONLY (source: backend/src/middleware/orgScope.middleware.js)
// Multi-tenant scoping: every query is pinned to one organisation.
// =============================================================

// export default (req, res, next) :
//   super_admin          -> req.scope = { isSuperAdmin: true } (sees everything)
//   user has organisation -> req.scope = { organisationId, isSuperAdmin: false }
//   user has NO org       -> 403 'User does not belong to any organisation'
//   services copy req.scope.organisationId into every mongo query -> tenant isolation
