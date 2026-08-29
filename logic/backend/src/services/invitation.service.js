// =============================================================
// invitation.service.js  ->  ALGORITHM ONLY (source: backend/src/services/invitation.service.js)
// =============================================================

// INVITABLE_ROLES: super_admin -> [org_admin, teacher]; org_admin -> [teacher]; nobody invites super_admin

// createInvite(inviterId, targetEmail, role, orgId, name?) :
//   role not allowed for inviter's role -> 403
//   org must exist + not be suspended
//   email normalized; existing ACTIVE user -> 409 'already exists'
//   teacher invites enforce the org plan maxTeachers seat limit (402)
//   random 32-byte token valid 7 days:
//     existing inactive user -> re-point role/org + hashed invite token + expiry
//     new user -> create INACTIVE user with hashed token
//   queue invite email (raw token only in the link); publish 'user.invited'

// acceptInvite(token, password, name?) :
//   find user by sha256(token) + inactive + unexpired -> else 400 'invalid or expired'
//   set password (hook hashes), activate, clear invite fields
//   issue access + refresh token pair (log the user straight in)
