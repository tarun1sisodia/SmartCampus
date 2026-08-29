// =============================================================
// migrate.js  ->  ALGORITHM ONLY (source: backend/scripts/migrate.js)
// =============================================================

// load env -> connect DB -> run ordered data migrations (schema fixes across collections)
//   -> disconnect (safe to re-run; idempotent steps)
