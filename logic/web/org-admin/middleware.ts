// =============================================================
// middleware.ts (org-admin)  ->  ALGORITHM ONLY (source: web/org-admin/middleware.ts)
// =============================================================

// edge route gate:
//   session cookie 'sc_session' == '1' OR path starts with /login -> allow
//   otherwise redirect to /login
//   NOTE: the cookie is only a FLAG — real auth is the Bearer token enforced by the API
//   (tokens are never put in cookies readable by middleware/XSS)
