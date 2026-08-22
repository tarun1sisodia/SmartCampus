import crypto from 'crypto';
import Session from '../models/Session.model.js';
import Attendance from '../models/Attendance.model.js';
import { sendSuccess, sendError } from '../utils/apiResponse.js';

const SECRET_KEY = process.env.QR_SECRET_KEY || 'super_secret_attendance_salt';

const generateCurrentToken = (sessionId) => {
  const timeSlot = Math.floor(Date.now() / 15000);
  const data = `${sessionId}:${timeSlot}`;
  return crypto.createHmac('sha256', SECRET_KEY).update(data).digest('hex').substring(0, 12);
};

const isTokenValid = (token, sessionId) => {
  const currentSlot = Math.floor(Date.now() / 15000);
  const data1 = `${sessionId}:${currentSlot}`;
  const data2 = `${sessionId}:${currentSlot - 1}`;
  
  const token1 = crypto.createHmac('sha256', SECRET_KEY).update(data1).digest('hex').substring(0, 12);
  const token2 = crypto.createHmac('sha256', SECRET_KEY).update(data2).digest('hex').substring(0, 12);
  
  return token === token1 || token === token2;
};

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

    if (!isTokenValid(token, sessionId)) {
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
    });

    sendSuccess(res, { message: 'Attendance successfully marked via QR!', data: attendance });
  } catch (err) {
    next(err);
  }
};

export default { generateDynamicQr, verifyQrAttendance };
