// =============================================================
// secure_storage_service.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/core/services/secure_storage_service.dart)
// Keychain/Keystore storage for the JWT tokens.
// =============================================================

// class SecureStorageService (wraps flutter_secure_storage) :
//   writeTokens(access, refresh) -> save both tokens under 'access_token' / 'refresh_token'
//   readAccessToken() / readRefreshToken() -> read one token (null if absent)
//   deleteTokens() -> deleteAll (used on logout / session expiry)
//   + static legacy helpers (saveTokens, getAccessToken, getRefreshToken, clearTokens)
//     kept as aliases so old modules still compile during migration
