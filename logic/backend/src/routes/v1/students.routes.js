// =============================================================
// students.routes.js  ->  ALGORITHM ONLY (source: backend/src/routes/v1/students.routes.js)
// =============================================================

// GET    /                auth + orgScope                     -> list (?sessionId for a class)
// POST   /                auth + rbac(super,org_admin) + validate(createStudentSchema)
// POST   /import          auth + rbac(super,org_admin) + upload.single('file') + verifyUploadedContent
// GET    /:id             auth + orgScope
// PUT    /:id             auth + rbac(super,org_admin)
// DELETE /:id             auth + rbac(super,org_admin)        // soft delete
// POST   /:id/photo       auth + rbac(super,org_admin,teacher) + upload + verifyUploadedContent
// DELETE /:id/photo       auth + rbac(super,org_admin,teacher)
