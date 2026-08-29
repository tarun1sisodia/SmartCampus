// =============================================================
// middleware.ts (super-admin)  ->  ALGORITHM ONLY (source: web/super-admin/middleware.ts)
// =============================================================

// same gate as org-admin: cookie 'sc_session' == '1' or /login -> allow, else redirect /login
// (flag cookie only — the API does real auth via the bearer token)
