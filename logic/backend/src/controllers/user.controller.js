// =============================================================
// user.controller.js  ->  ALGORITHM ONLY (source: backend/src/controllers/user.controller.js)
// =============================================================

// listTeachers / listUsers : clamp page >=1, limit 1..100 -> paginated service call
// updateUserRole : super-admin only role change
// deactivate : service (self/org/role guards inside)
// sendInvite : createInvite (role rules enforced in service)
// acceptInvite : accept token+password -> return access token + user
// resendInvite : only PENDING (inactive) users; same-org check (IDOR fix) -> re-run createInvite
// changePassword / adminResetPassword : delegate to service
// uploadProfilePhoto : req.file required -> service.uploadProfilePhoto(buffer)
// deleteProfilePhoto : service
// getMe : current user + organisation info (name/status/subscription/type)
// updateMe : whitelist-only profile update
