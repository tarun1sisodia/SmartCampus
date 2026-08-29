// =============================================================
// auth.api.test.js  ->  ALGORITHM ONLY (source: backend/tests/integration/auth.api.test.js)
// =============================================================

// integration tests (supertest against the express app with mocked service):
//   POST /auth/login 200 -> body has accessToken + user.role
//   response Set-Cookie carries the httpOnly refreshToken cookie (strict + secure flags)
