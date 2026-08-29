// =============================================================
// (dashboard)/users/page.tsx (super-admin)  ->  ALGORITHM ONLY
// (source: web/super-admin/app/(dashboard)/users/page.tsx)
// =============================================================

// useQuery getUsers({ role filter, page }) -> admin user table (name/email/org/role/status)
// mutations per row:
//   resetPassword  -> POST /users/:id/reset-password (emails the user)
//   deactivate     -> DELETE /users/:id
//   promote/demote -> PATCH /users/:id (role change)
// all -> toast + invalidate the users query
