import qrService from '../services/qr.service.js';
import Session from '../models/Session.model.js';
import Attendance from '../models/Attendance.model.js';
import { sendSuccess } from '../utils/apiResponse.js';
import logger from '../config/logger.js';

/** Optional campus-level geofence: when QR_GEOFENCE_LAT/LON/RADIUS_METERS are
 *  configured, QR-verified attendance must originate inside the circle. */
const GEOFENCE = {
  lat: process.env.QR_GEOFENCE_LAT ? parseFloat(process.env.QR_GEOFENCE_LAT) : null,
  lon: process.env.QR_GEOFENCE_LON ? parseFloat(process.env.QR_GEOFENCE_LON) : null,
  radiusMeters: process.env.QR_GEOFENCE_RADIUS_METERS ? parseFloat(process.env.QR_GEOFENCE_RADIUS_METERS) : null,
};

const isGeofenceConfigured = () =>
  GEOFENCE.lat !== null && GEOFENCE.lon !== null && GEOFENCE.radiusMeters !== null;

/** Haversine distance in meters. */
const distanceMeters = (lat1, lon1, lat2, lon2) => {
  const R = 6371e3;
  const phi1 = (lat1 * Math.PI) / 180;
  const phi2 = (lat2 * Math.PI) / 180;
  const dPhi = ((lat2 - lat1) * Math.PI) / 180;
  const dLambda = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dPhi / 2) ** 2 + Math.cos(phi1) * Math.cos(phi2) * Math.sin(dLambda / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
};

/** Session is "live" for QR marking: same calendar day and within the
 *  configured window (startTime −10 min … endTime +30 min), when times exist. */
const isSessionLive = (session, now = new Date()) => {
  const sessionDay = new Date(session.date);
  sessionDay.setHours(0, 0, 0, 0);
  const dayEnd = new Date(sessionDay);
  dayEnd.setDate(dayEnd.getDate() + 1);
  if (now < sessionDay || now >= dayEnd) return false;

  const parseHm = (hm) => {
    const m = /^(\d{1,2}):(\d{2})$/.exec(String(hm || ''));
    if (!m) return null;
    const d = new Date(sessionDay);
    d.setHours(parseInt(m[1], 10), parseInt(m[2], 10), 0, 0);
    return d;
  };

  const start = parseHm(session.startTime);
  const end = parseHm(session.endTime);
  if (start && now < start.getTime() - 10 * 60 * 1000) return false;
  if (end && now > end.getTime() + 30 * 60 * 1000) return false;
  return true;
};

// Generate Dynamic QR Token for a specific session
export const generateDynamicQr = async (req, res, next) => {
  try {
    const { sessionId } = req.params;

    const query = { _id: sessionId };
    if (req.user.role !== 'super_admin') {
      // Tenant + ownership: a teacher may only mint tokens for their own
      // sessions inside their own organisation.
      query.organisation = req.scope.organisationId;
      query.teacher = req.user.id;
    }

    const session = await Session.findOne(query);
    if (!session) {
      return res.status(404).json({ success: false, message: 'Session not found' });
    }

    const token = qrService.generateToken(sessionId);
    sendSuccess(res, { token, expiresIn: qrService.secondsUntilNextSlot() });
  } catch (err) {
    next(err);
  }
};

// Verify QR Attendance (marks the *authenticated* user present).
// Intended for the student role; teachers/org-admins are rejected because
// marking a staff member present would corrupt attendance records.
export const verifyQrAttendance = async (req, res, next) => {
  try {
    const { sessionId, token, lat, lon } = req.body;
    const userId = req.user.id;

    if (!sessionId || !token) {
      return res.status(400).json({ success: false, message: 'Session ID and token are required' });
    }

    if (!qrService.validateToken(token, sessionId)) {
      return res.status(400).json({ success: false, message: 'QR code has expired or is invalid. Please scan again.' });
    }

    // The scanned token proves the user was physically near the displayed QR,
    // but the session must still belong to the user's organisation.
    const session = await Session.findById(sessionId);
    if (!session) {
      return res.status(404).json({ success: false, message: 'Session not found' });
    }
    if (String(session.organisation) !== String(req.user.organisation)) {
      return res.status(403).json({ success: false, message: 'Session belongs to another organisation' });
    }

    // Attendance can only be marked while the session is live (same day,
    // inside the start/end window) — prevents retroactive marking.
    if (!isSessionLive(session)) {
      return res.status(400).json({ success: false, message: 'This session is not currently active' });
    }

    // Geofence: enforced when campus coordinates are configured; otherwise
    // the device coordinates are stored for auditing.
    const hasCoords = Number.isFinite(lat) && Number.isFinite(lon);
    if (isGeofenceConfigured()) {
      if (!hasCoords) {
        return res.status(400).json({ success: false, message: 'Location is required for QR attendance' });
      }
      const dist = distanceMeters(lat, lon, GEOFENCE.lat, GEOFENCE.lon);
      if (dist > GEOFENCE.radiusMeters) {
        logger.warn(`QR geofence rejection: user ${userId} is ${Math.round(dist)}m from campus`);
        return res.status(403).json({ success: false, message: 'You appear to be outside the campus area' });
      }
    }

    let attendance = await Attendance.findOne({ session: sessionId, student: userId });
    if (attendance) {
      if (attendance.status === 'present') {
        return sendSuccess(res, { message: 'Attendance already marked as present' });
      }
      attendance.status = 'present';
      attendance.markedBy = userId;
      attendance.markedVia = 'qr';
      attendance.qrTokenUsed = token;
      if (hasCoords) attendance.locationData = { lat, lon };
      await attendance.save();
      return sendSuccess(res, { message: 'Attendance updated to present' });
    }

    attendance = await Attendance.create({
      session: sessionId,
      student: userId,
      organisation: session.organisation,
      status: 'present',
      markedBy: userId,
      markedVia: 'qr',
      qrTokenUsed: token,
      locationData: hasCoords ? { lat, lon } : undefined
    });

    sendSuccess(res, { message: 'Attendance successfully marked via QR!', data: attendance });
  } catch (err) {
    next(err);
  }
};

export default { generateDynamicQr, verifyQrAttendance };
