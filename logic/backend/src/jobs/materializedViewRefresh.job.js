// =============================================================
// materializedViewRefresh.job.js  ->  ALGORITHM ONLY (source: backend/src/jobs/materializedViewRefresh.job.js)
// =============================================================

// no cron needed — view refresh is event-driven:
//   see events/subscribers/updateAnalytics.subscriber.js (refreshes on every attendance.marked)
