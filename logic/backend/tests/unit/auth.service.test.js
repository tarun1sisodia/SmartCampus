// =============================================================
// auth.service.test.js  ->  ALGORITHM ONLY (source: backend/tests/unit/auth.service.test.js)
// =============================================================

// unit tests with the DB mocked:
//   login: correct creds -> tokens + safe user ; wrong password -> 401 ; looks up active user only
//   refresh: valid + stored -> rotated pair ; stored-hash missing -> reuse detection revokes all
