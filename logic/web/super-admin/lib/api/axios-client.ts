// =============================================================
// axios-client.ts (super-admin)  ->  ALGORITHM ONLY (source: web/super-admin/lib/api/axios-client.ts)
// =============================================================

// identical pattern to org-admin:
//   injected redux store ; request interceptor adds Bearer token
//   401 -> single retry: POST /auth/refresh -> setCredentials -> replay request
//   refresh failure -> clearCredentials
