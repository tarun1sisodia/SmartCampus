// =============================================================
// auth.controller.js  ->  ALGORITHM ONLY (source: backend/src/controllers/auth.controller.js)
// =============================================================

// REFRESH_COOKIE: httpOnly + secure(prod) + sameSite strict + path /api/v1/auth + 7 days

// login : authService.login -> set refreshToken as httpOnly cookie + return { accessToken, refreshToken, user }
// refresh : token from cookie OR body -> service rotates -> reset cookie -> return new pair
// logout : revoke stored token (if any) + clearCookie -> 'Logged out'
// forgotPassword : pass email through -> always-generic response
// resetPassword : { token, newPassword } -> service -> 'Password updated'
