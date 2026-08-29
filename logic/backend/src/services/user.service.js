// =============================================================
// user.service.js  ->  ALGORITHM ONLY (source: backend/src/services/user.service.js)
// =============================================================

// listTeachers(orgId, page, limit, isSuperAdmin) : role=teacher query (org-scoped), paginate, sort name
// listUsers({ orgId?, role?, page, limit, isSuperAdmin }) : super-admin listing + org name populate

// deactivateUser(userId, requesterOrg, isSuperAdmin, requesterId) :
//   cannot deactivate YOURSELF (400); user missing 404; other org 403 (unless super)
//   org_admin may not deactivate org_admin/super_admin (403)
//   set isActive=false; revoke all refresh tokens (kill sessions instantly); write AuditLog

// updateUserRole(userId, role, ...) : super admin only; save; revoke refresh tokens
//   (stale role claims die immediately); AuditLog old/new role

// changePassword(userId, old, new) :
//   bcrypt.compare old -> mismatch 400; assign plaintext (hook hashes once)
//   revoke all refresh tokens; AuditLog; 'sign in again'

// adminResetPassword(userId, ...) : org check -> reuse forgotPassword(email) flow (queued email); AuditLog

// updateProfile(userId, payload) : whitelist ONLY [name, avatar, contact] (mass-assignment guard) -> findByIdAndUpdate
// uploadProfilePhoto(userId, buffer) : cloudinary upload users/<id>/profile -> save avatar url
// deleteProfilePhoto(userId) : cloudinary destroy + clear avatar field
