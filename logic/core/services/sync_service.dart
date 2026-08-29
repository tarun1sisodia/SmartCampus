// =============================================================
// sync_service.dart  ->  ALGORITHM ONLY (source: frontend/lib/core/services/sync_service.dart)
// Uploads offline (pending) attendance to the server with batching, conflict
// resolution and exponential-backoff retry.
// =============================================================

// class SyncService(apiClient, db, hiveService, appFeedbackService) :
//   flag _isSyncing -> prevent two syncs running at the same time

// syncPendingAttendance() :
//   if already syncing -> return immediately; set _isSyncing = true (finally resets it)
//   SELECT pending rows WHERE synced = 0 AND (nextRetryAt is null or due) AND retryCount < 8
//   if none -> stop
//   process rows in batches of max 50 :
//     group the batch rows by sessionId
//     for each session -> fetch server attendance timestamps (see helper below)
//     for each row compare local vs server timestamp:
//       server newer  -> CONFLICT: collect id (server wins)
//       otherwise     -> add row to recordsToSync
//     delete conflicted rows locally + store/show a conflict notification
//     POST /attendance/sync {records: [sessionId, studentId, status, remarks, timestamp]}
//     on success -> delete the synced rows from pending_attendance
//     on failure -> schedule retry for that batch (helper below)

// _fetchServerTimestampsBySession(sessionId) :
//   GET /attendance/session/<sessionId>
//   build map {studentId -> server timestamp (UTC)}; any error -> return empty map (treat as no conflicts)

// _scheduleRetry(records, error) :
//   for each row: retryCount += 1, nextRetryAt = now + backoff, save lastError
//   (failed batches will be picked up again by the next sync run)

// _backoffMinutes(retry) : 1, 2, 4, 8 ... capped at 60 minutes (1 << retry-1)

// _storeConflictNotification(count) :
//   add count to 'sync_conflict_count' counter in Hive settings box
//   show a warning snackbar (throttled) via AppFeedbackService
