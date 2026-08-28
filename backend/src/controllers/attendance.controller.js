import attendanceService from '../services/attendance.service.js';
import { sendSuccess } from '../utils/apiResponse.js';
import Session from '../models/Session.model.js';
import Attendance from '../models/Attendance.model.js';

/** Whitelist of client-settable session fields (prevents mass assignment). */
const SESSION_FIELDS = ['subject', 'course', 'semester', 'section', 'date', 'startTime', 'endTime', 'topic', 'isHoliday'];

export const createSession = async (req, res, next) => {
  try {
    const payload = {};
    for (const field of SESSION_FIELDS) {
      if (req.body[field] !== undefined) payload[field] = req.body[field];
    }
    payload.teacher = req.user.id;
    // Non-super-admins are pinned to their own organisation by orgScope.
    payload.organisation = req.user.role === 'super_admin'
      ? (req.body.organisationId || req.user.organisation)
      : req.scope.organisationId;

    const session = await Session.create(payload);
    sendSuccess(res, session, 201);
  } catch (err) {
    next(err);
  }
};

export const listSessions = async (req, res, next) => {
  try {
    const { date, month, subjectId, courseId, startDate, endDate } = req.query;
    const teacherId = req.user.id;
    const organisationId = req.scope?.organisationId;
    const isSuperAdmin = req.user.role === 'super_admin';

    let sessions;
    if (month) {
      // Calendar view (YYYY-MM) — used by the Flutter calendar screen.
      sessions = await attendanceService.getSessionsByMonth(teacherId, String(month), organisationId, isSuperAdmin);
    } else {
      sessions = await attendanceService.listSessions(
        teacherId,
        organisationId,
        isSuperAdmin,
        { date, subjectId, courseId, startDate, endDate }
      );
    }

    sendSuccess(res, sessions);
  } catch (err) {
    next(err);
  }
};

export const getSession = async (req, res, next) => {
  try {
    const query = { _id: req.params.sessionId };
    if (!req.scope.isSuperAdmin) query.organisation = req.scope.organisationId;

    const session = await Session.findOne(query).populate('subject course semester section teacher', 'name code title email');
    if (!session) {
      return res.status(404).json({ success: false, message: 'Session not found' });
    }

    const attendance = await Attendance.find({ session: session._id }).populate('student', 'name rollNumber photo');
    sendSuccess(res, { ...session.toJSON(), attendance });
  } catch (err) {
    next(err);
  }
};

export const markBulk = async (req, res, next) => {
  try {
    const { sessionId, attendance } = req.body;
    const isSuperAdmin = req.user.role === 'super_admin';
    const orgId = req.scope.organisationId || req.body.organisationId;

    const result = await attendanceService.markBulk(
      sessionId,
      attendance,
      req.user.id,
      orgId,
      isSuperAdmin
    );

    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export const getBySession = async (req, res, next) => {
  try {
    const query = { session: req.params.sessionId };
    if (!req.scope.isSuperAdmin) query.organisation = req.scope.organisationId;
    const records = await Attendance.find(query).populate('student', 'name rollNumber');
    sendSuccess(res, records);
  } catch (err) {
    next(err);
  }
};

export const studentSummary = async (req, res, next) => {
  try {
    const isSuperAdmin = req.user.role === 'super_admin';
    const parsedSem = req.query.semesterId ? String(req.query.semesterId) : null;
    const result = await attendanceService.getStudentSummary(
      req.params.studentId,
      req.scope.organisationId,
      isSuperAdmin,
      parsedSem
    );
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export const syncOffline = async (req, res, next) => {
  try {
    const { records } = req.body;
    const orgId = req.scope.organisationId;

    const result = await attendanceService.syncOffline(req.user.id, records, orgId);
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export const listSessionsByMonth = async (req, res, next) => {
  try {
    const { month } = req.query; // Format YYYY-MM
    if (!month || !/^\d{4}-\d{2}$/.test(String(month))) {
      return res.status(400).json({ success: false, message: 'month query param must be in YYYY-MM format' });
    }
    const isSuperAdmin = req.user.role === 'super_admin';
    const orgId = req.scope.organisationId;

    const result = await attendanceService.getSessionsByMonth(req.user.id, String(month), orgId, isSuperAdmin);
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export default { createSession, listSessions, getSession, markBulk, getBySession, studentSummary, syncOffline, listSessionsByMonth };
