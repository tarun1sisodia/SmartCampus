// =============================================================
// orgs.routes.js  ->  ALGORITHM ONLY (source: backend/src/routes/v1/orgs.routes.js)
// =============================================================

// POST   /        auth + rbac(super_admin) + validate(createOrgSchema) -> create
// GET    /        auth + rbac(super_admin) -> list
// GET    /:orgId  auth + rbac(super_admin) -> get
// PATCH  /:orgId  auth + rbac(super_admin) -> update (suspend/activate/details)
