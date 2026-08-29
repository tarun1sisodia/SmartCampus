// =============================================================
// RefreshToken.model.js  ->  ALGORITHM ONLY (source: backend/src/models/RefreshToken.model.js)
// Stores SHA-256 HASHES of refresh tokens so a DB leak can't be replayed.
// =============================================================

// schema: tokenHash (unique), user ref, expiresAt
// index { user } ; index { expiresAt } with expireAfterSeconds:0 -> mongo TTL auto-deletes expired rows
