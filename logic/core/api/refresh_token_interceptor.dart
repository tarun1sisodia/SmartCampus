// =============================================================
// refresh_token_interceptor.dart  ->  ALGORITHM ONLY (source: frontend/lib/core/api/refresh_token_interceptor.dart)
// Auto token refresh on 401 with single-flight (only ONE refresh at a time).
// =============================================================

// class RefreshTokenInterceptor (Dio Interceptor) :
//   field _refreshFuture -> shared in-flight refresh call, so parallel 401s await the SAME refresh
//     (without this, 2 requests could both refresh; the 2nd uses a revoked token and logs the user out)

// onError(err, handler) :
//   if error is 401 AND path is NOT /auth/refresh or /auth/logout (avoid infinite loop) :
//     read refresh token; if none -> clear tokens + logout, pass error through
//     await the single shared refresh call (create it if none running)
//     if refresh failed -> clear tokens + logout
//     else -> replace Authorization header with the new access token and RETRY the original request
//     resolve the handler with the retried response
//   otherwise -> pass the error through normally

// _performRefresh(refreshToken) :
//   use a FRESH Dio (no interceptors, so no loops) with the same baseUrl/timeouts
//   POST /auth/refresh with {refreshToken}
//   if not 200/201 or accessToken missing -> return null (failed)
//   save new access token + new refresh token (fallback to old one if server didn't rotate it)
//   return the new access token wrapped in _RefreshResult

// _isRefreshOrLogout(path) -> true if path contains refresh or logout endpoint

// _clearTokensAndLogout() :
//   delete tokens from secure storage
//   if AuthBloc registered in getIt -> fire AuthLogoutRequested (whole app reacts: router goes to login)
