// =============================================================
// user-api.ts (org-admin)  ->  ALGORITHM ONLY (source: web/org-admin/lib/api/endpoints/user-api.ts)
// =============================================================

// mapTeacher(backendUser) -> slim Teacher shape (id/name/email/status) for the UI
// getTeachers(params page/limit) -> GET /users/teachers -> { data, total, page, limit }
// inviteTeacher(payload)  -> POST /users/invite { ...payload, role: 'teacher' }
// deactivateTeacher(id)  -> DELETE /users/<id>
// resendInvite(id)       -> POST /users/<id>/resend-invite
