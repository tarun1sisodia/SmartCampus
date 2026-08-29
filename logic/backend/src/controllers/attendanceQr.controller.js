// =============================================================
// attendanceQr.controller.js  ->  ALGORITHM ONLY (source: backend/src/controllers/attendanceQr.controller.js)
// The QR attendance flow (generate for teachers, verify for students).
// =============================================================

// GEOFENCE from env (QR_GEOFENCE_LAT/LON/RADIUS_METERS) — active only when all three set

// distanceMeters : haversine between scan coords and campus center

// isSessionLive(session, now) :
//   same calendar day AND within [startTime - 10min, endTime + 30min] (when times exist)
//   -> blocks marking attendance for past/future sessions

// generateDynamicQr(sessionId) :
//   teacher may only mint tokens for THEIR OWN session in THEIR org (query pinned unless super admin)
//   404 when not found -> return { token, expiresIn: secondsUntilNextSlot() }

// verifyQrAttendance({ sessionId, token, lat, lon }) :  marks the CALLING user present
//   both fields required; qrService.validateToken (accepts current/prev 15s slot) -> else 400 'expired, scan again'
//   session must exist AND belong to the caller's organisation (403 cross-org)
//   session must be live (isSessionLive) -> else 400 'not currently active'
//   geofence configured: coords REQUIRED + distance <= radius -> else 403 'outside campus'
//   existing (session, student) row:
//     already present -> idempotent 'already marked'
//     else -> flip to present + markedVia 'qr' + store token + location
//   no row -> create present record with qr metadata
