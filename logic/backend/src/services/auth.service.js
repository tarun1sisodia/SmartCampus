// =============================================================
// auth.service.js  ->  ALGORITHM ONLY (source: backend/src/services/auth.service.js)
// =============================================================

// hashToken(token) -> sha256 hex (refresh/reset/invite tokens are only stored hashed)

// login(email, password) :
//   normalize email (trim + lowercase); find ACTIVE user with +password
//   not found or bcrypt mismatch -> identical 401 'Invalid credentials' (no user enumeration)
//   generate access + refresh tokens; store sha256(refresh) in RefreshToken with 7-day expiry
//   update lastLogin; return { tokens, user (safe toJSON) }

// refreshAccessToken(oldRefreshToken) :
//   1. verify JWT signature first (cheap) -> invalid = 401
//   2. look up stored hash; load the user (inactive = 401)
//      hash NOT found but signature valid => TOKEN REUSE/THEFT:
//        revoke ALL the user's refresh tokens + 401
//   3. stored token expired -> delete it + 401
//   4. ROTATE: overwrite stored hash with sha256(new refresh token), sliding 7-day expiry
//      return fresh { accessToken, refreshToken }

// logout(refreshToken) : verify + delete that one stored hash; invalid token = silent no-op

// forgotPassword(email) :
//   ALWAYS return the same generic message ('if an account exists...') whether or not it does
//   if user exists: random 32-byte token -> store sha256(token) + 1h expiry -> queue reset email

// resetPassword(token, newPassword) :
//   find user by sha256(token) with unexpired reset window -> else 400
//   assign PLAINTEXT password (pre-save hook hashes once) + clear token fields + save
//   revoke all refresh tokens (stolen sessions die) -> 'Password updated'

// AuthError = Error carrying an http status for the global handler
