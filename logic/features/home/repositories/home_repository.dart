// =============================================================
// home_repository.dart  ->  ALGORITHM ONLY (source: frontend/lib/features/home/repositories/home_repository.dart)
// Today's sessions with a midnight-expiring Hive cache.
// =============================================================

// class HomeRepository(ApiClient, HiveService) :
//   cache keys: 'today_sessions' + 'today_sessions_expiry'

// fetchTodaySessions() :
//   GET /sessions?date=today
//   unwrap list from payload['data'] | payload['sessions'] | payload itself
//   map json -> SessionModel list
//   cache the RAW json list + expiry timestamp (next UTC midnight) into session_cache_box
//   return sessions; error -> rethrow (bloc decides fallback)

// getCachedTodaySessions() :
//   read expiry; missing/unparsable/expired -> delete both cache keys, return null
//   else decode cached json -> list of SessionModel (null when nothing cached)

// _midnightUtc() : next UTC midnight = start of tomorrow (UTC)
