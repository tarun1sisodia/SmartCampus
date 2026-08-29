// =============================================================
// qr.service.js  ->  ALGORITHM ONLY (source: backend/src/services/qr.service.js)
// Rolling QR tokens: TOTP-style HMAC over 15-second time slots.
// =============================================================

// currentSlot() = floor(now / 15000)  -> time slot number

// generateToken(sessionId) :
//   HMAC-SHA256(QR_SECRET, '<sessionId>:<slot>') -> first 16 hex chars (64 bits)

// validateToken(token, sessionId) :
//   token must be exactly 16 chars
//   timingSafeEqual against PREVIOUS slot's token OR CURRENT slot's token
//   (tolerates a scan right at the rotation boundary; constant-time compare prevents timing attacks)

// secondsUntilNextSlot() = 15 - (seconds % 15)  -> told to the app so it refreshes the QR in time
