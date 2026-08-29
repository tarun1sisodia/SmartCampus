// =============================================================
// auth_repository.dart  ->  ALGORITHM ONLY (source: frontend/lib/features/auth/repositories/auth_repository.dart)
// All auth API calls + token storage.
// =============================================================

// class AuthRepository(ApiClient, SecureStorageService) :

// login(email, password) :
//   POST /auth/login {email, password} with 10s connect timeout
//   on 200/201 -> extract payload (helper below)
//   require accessToken + refreshToken + user json; anything missing = throw 'invalid payload'
//   save both tokens in secure storage
//   return UserModel from user json; non-200 or error -> rethrow (null = invalid credentials)

// _extractPayload(raw) :
//   if response is a map with a 'data' map inside -> unwrap it; else use the map as-is
//   anything else -> throw 'unexpected API response format'

// logout() :
//   try POST /auth/logout (ignore any error)
//   ALWAYS delete stored tokens afterwards (finally)

// forgotPassword(email)    -> POST /auth/forgot-password {email}
// resetPassword(token, pw) -> POST /auth/reset-password {token, newPassword}
// getAccessToken() / getRefreshToken() -> read from secure storage

// getCurrentUser() : GET /users/me -> unwrap payload -> UserModel from data.user ?? data

// refreshTokenPair() :
//   read refresh token; absent -> false
//   POST /auth/refresh {refreshToken}
//   non-200 or no accessToken -> false
//   save new tokens (keep old refresh token if server didn't rotate it) -> true

// isAuthenticated() : access token exists in storage
