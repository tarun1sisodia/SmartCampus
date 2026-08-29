// =============================================================
// axios-client.ts (org-admin)  ->  ALGORITHM ONLY (source: web/org-admin/lib/api/axios-client.ts)
// =============================================================

// injectStore(store) — the store registers itself at boot so interceptors can read auth state

// axios instance baseURL NEXT_PUBLIC_API_URL (default localhost:5000/api/v1)

// request interceptor: token in redux auth state -> attach 'Authorization: Bearer <token>'
// response interceptor (401 auto-refresh):
//   401 + not already retried + refresh token present:
//     POST /auth/refresh with the refresh token (plain axios, no interceptor loop)
//     success -> dispatch setCredentials(new pair) -> REPLAY the original request
//     failure -> dispatch clearCredentials (user must log in again)
