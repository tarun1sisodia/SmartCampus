import Session from '../models/Session.model.js';
import Attendance from '../models/Attendance.model.js';
import { sendSuccess, sendError } from '../utils/apiResponse.js';
import qrService from '../services/qr.service.js';

const generateCurrentToken = qrService.generateToken;

// Generate Dynamic QR Token for a specific session
export const generateDynamicQr = async (req, res, next) => {
  try {
    const { sessionId } = req.params;
    
    // Verify session belongs to teacher
    const session = await Session.findById(sessionId);
    if (!session) {
      return sendError(res, 'Session not found', 404);
    }
    
    if (session.teacher.toString() !== req.user.id.toString() && req.user.role !== 'super_admin') {
      return sendError(res, 'Unauthorized to generate QR for this session', 403);
    }

    const token = generateCurrentToken(sessionId);
    const expiresIn = 15 - Math.floor((Date.now() / 1000) % 15);
    
    sendSuccess(res, { token, expiresIn });
  } catch (err) {
    next(err);
  }
};

// Verify QR Attendance (Student side)
export const verifyQrAttendance = async (req, res, next) => {
  try {
    const { sessionId, token } = req.body;
    const studentId = req.user.id; // From auth middleware

    if (!sessionId || !token) {
      return sendError(res, 'Session ID and token are required', 400);
    }

    if (!qrService.validateToken(token, sessionId)) {
      return sendError(res, 'QR code has expired or is invalid. Please scan again.', 400);
    }

    const session = await Session.findById(sessionId);
    if (!session) {
      return sendError(res, 'Session not found', 404);
    }

    // Check if already marked
    let attendance = await Attendance.findOne({ session: sessionId, student: studentId });
    if (attendance) {
      if (attendance.status === 'present') {
        return sendSuccess(res, { message: 'Attendance already marked as present' });
      } else {
        attendance.status = 'present';
        attendance.markedBy = studentId;
        attendance.markedVia = 'qr';
        attendance.qrTokenUsed = token;
        if (req.body.lat != null && req.body.lon != null) {
          attendance.locationData = { lat: req.body.lat, lon: req.body.lon };
        }
        await attendance.save();
        return sendSuccess(res, { message: 'Attendance updated to present' });
      }
    }

    // Create new attendance record
    attendance = await Attendance.create({
      session: sessionId,
      student: studentId,
      organisation: session.organisation,
      status: 'present',
      markedBy: studentId, // Indicates student marked their own via QR
      markedVia: 'qr',
      qrTokenUsed: token,
      locationData: req.body.lat != null && req.body.lon != null
        ? { lat: req.body.lat, lon: req.body.lon }
        : undefined,
    });

    sendSuccess(res, { message: 'Attendance successfully marked via QR!', data: attendance });
  } catch (err) {
    next(err);
  }
};

export default { generateDynamicQr, verifyQrAttendance };
