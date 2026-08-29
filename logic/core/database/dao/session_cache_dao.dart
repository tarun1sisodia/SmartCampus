// =============================================================
// session_cache_dao.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/core/database/dao/session_cache_dao.dart)
// =============================================================

// class SessionCacheDao (wraps the session_cache table) :
//   upsert(cacheKey, jsonData, expiresAtIso) -> insert/replace row, updatedAt = now (UTC ISO)
//   getByKey(cacheKey)                       -> select row by key, null if not found
//   deleteByKey(cacheKey)                    -> remove one cached entry
//   deleteExpired()                          -> delete all rows where expiresAt <= now
