// =============================================================
// leaderElection.js  ->  ALGORITHM ONLY (source: backend/src/jobs/leaderElection.js)
// =============================================================

// startLeaderElection() :
//   every 30s: redis SET 'leader:singleton-tasks' NX EX 60
//   won -> this node runs singleton chores (cleanups, report triggers) for the next minute
//   errors swallowed (retry next tick)
