// =============================================================
// backup.routes.js  ->  ALGORITHM ONLY (source: backend/src/routes/v1/backup.routes.js)
// =============================================================

// POST /create          auth + rbac(super_admin) -> run full backup
// GET  /list            auth + rbac(super_admin) -> backup history
// POST /restore/:id     auth + rbac(super_admin) -> 501 (not implemented)
