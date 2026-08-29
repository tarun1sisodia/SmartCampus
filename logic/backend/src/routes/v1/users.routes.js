// =============================================================
// users.routes.js  ->  ALGORITHM ONLY (source: backend/src/routes/v1/users.routes.js)
// =============================================================

// POST /invite            auth + rbac(super,org_admin) + validate(inviteSchema)
// POST /accept-invite     sensitiveLimiter + validate(acceptInviteSchema)     // public
// POST /:id/resend[-invite] auth + rbac(super,org_admin)
// GET  /teachers          auth + rbac(super,org_admin)
// GET  /                  auth + rbac(super_admin)                          // all users
// PATCH /:id              auth + rbac(super_admin) + validate(updateRoleSchema)
// DELETE /:id             auth + rbac(super,org_admin)                      // deactivate
// POST /:id/reset-password auth + rbac(super,org_admin) + sensitiveLimiter
// GET  /me                auth
// PATCH /me               auth + validate(updateProfileSchema)
// POST /change-password   auth + sensitiveLimiter + validate(changePasswordSchema)
// POST /me/photo          auth + upload.single('photo')
// DELETE /me/photo        auth
