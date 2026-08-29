// =============================================================
// generateToken.js  ->  ALGORITHM ONLY (source: backend/src/utils/generateToken.js)
// JWT creation/verification (jsonwebtoken).
// =============================================================

// secrets from env (env.js validated them at boot); dev-only fallbacks; prod missing -> throw

// generateAccessToken(user)  -> jwt.sign { sub: userId, role, org } with ACCESS secret, TTL 15m
// generateRefreshToken(user) -> jwt.sign { sub: userId } with REFRESH secret, TTL 7 days
// verifyAccessToken / verifyRefreshToken -> jwt.verify with the matching secret
