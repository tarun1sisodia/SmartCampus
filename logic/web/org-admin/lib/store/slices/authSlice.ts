// =============================================================
// authSlice.ts (org-admin)  ->  ALGORITHM ONLY (source: web/org-admin/lib/store/slices/authSlice.ts)
// =============================================================

// state: { user, accessToken, refreshToken, isAuthenticated }
// persistAuth(state) -> sessionStorage['smartcampus.auth'] = json { user, tokens }
//   (session-scoped: survives reload, wiped when the tab/browser closes — tokens NEVER in cookies)
// hydrateAuth() -> read + parse that key at store creation (invalid/absent -> logged-out state)

// thunks:
//   login  -> loginApi -> fulfilled stores user+tokens ; rejected clears everything
//   logout -> logoutApi (ignore errors) then always clear
// reducers:
//   setCredentials (after refresh) / setAccessToken / clearCredentials (also wipes sessionStorage)
