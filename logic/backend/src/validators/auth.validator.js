// =============================================================
// auth.validator.js  ->  ALGORITHM ONLY (source: backend/src/validators/auth.validator.js)
// =============================================================

// passwordSchema : 8..128 chars + at least one lowercase, uppercase, digit
// loginSchema { email(valid, <=254), password(1..128) }
// inviteSchema { email, role enum, organisationId(ObjectId), name? }
// acceptInviteSchema { token, password: passwordSchema, name? }
// forgotSchema { email } ; resetSchema { token, newPassword: passwordSchema }
// updateRoleSchema { role enum } ; changePasswordSchema { oldPassword, newPassword }
// updateProfileSchema { name?, contact? } (whitelist only)
