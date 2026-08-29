// =============================================================
// authCookies.ts (org-admin)  ->  ALGORITHM ONLY (source: web/org-admin/lib/utils/authCookies.ts)
// =============================================================

// setSessionFlagCookie() -> document.cookie 'sc_session=1' (SameSite=Lax) — a NON-sensitive flag only
// clearSessionFlagCookie() -> expire it
// (real auth = Authorization header from redux; a token in a JS-readable cookie was removed for XSS safety)
