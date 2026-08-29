// =============================================================
// auth.routes.js  ->  ALGORITHM ONLY (source: backend/src/routes/v1/auth.routes.js)
// =============================================================

// POST /login           strictLimiter  + validate(loginSchema)      -> login
// POST /refresh         sensitiveLimiter                           -> refresh
// POST /logout          auth                                         -> logout
// POST /forgot-password strictLimiter  + validate(forgotSchema)     -> forgotPassword
// POST /reset-password  strictLimiter  + validate(resetSchema)      -> resetPassword
