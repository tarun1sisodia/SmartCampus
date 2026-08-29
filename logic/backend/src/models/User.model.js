// =============================================================
// User.model.js  ->  ALGORITHM ONLY (source: backend/src/models/User.model.js)
// =============================================================

// schema: name(trimmed), email(unique, required), password (select:false -> never returned by default),
//   role enum ['super_admin','org_admin','teacher'], organisation ref, invitedBy, inviteToken,
//   inviteExpires, resetPasswordToken, resetPasswordExpires, avatar,
//   fcmTokens[] { token, deviceId, createdAt }, isActive (default false — must accept invite),
//   lastLogin

// pre('save') hook: if password field changed -> bcrypt hash it ONCE here
//   (the single canonical hash — services always assign plaintext passwords)
// toJSON(): strip password + all token fields from every response
// index { organisation, role }
