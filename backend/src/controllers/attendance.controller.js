const attendanceService = require('../services/attendance.service');
const { sendSuccess } = require('../utils/apiResponse');
const Session = require('../models/Session.model');
const Attendance = require('../models/Attendance.model');

exports.createSession = async (req, res, next) => {
  try {
    const session = await Session.create({
      ...req.body,
      teacher: req.user.id,
      organisation: req.scope.organisationId || req.body.organisationId
    });
    sendSuccess(res, session, 201);
  } catch (err) {
    next(err);
  }
};

exports.listSessions = async (req, res, next) => {
  try {
    const query = {};
    if (!req.scope.isSuperAdmin) query.organisation = req.scope.organisationId;
    if (req.query.date) query.date = new Date(req.query.date);
    if (req.query.teacher) query.teacher = req.query.teacher;
    if (req.query.subject) query.subject = req.query.subject;

    const sessions = await Session.find(query).sort('-date');
    sendSuccess(res, sessions);
  } catch (err) {
    next(err);
  }
};

exports.markBulk = async (req, res, next) => {
  try {
    const { sessionId, attendance } = req.body;
    const isSuperAdmin = req.user.role === 'super_admin';
    const orgId = req.scope.organisationId || req.body.organisationId;
    
    // We can directly use the CQRS command or the service.
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

exports.getBySession = async (req, res, next) => {
  try {
    const query = { session: req.params.sessionId };
    if (!req.scope.isSuperAdmin) query.organisation = req.scope.organisationId;
    const records = await Attendance.find(query).populate('student', 'name rollNumber');
    sendSuccess(res, records);
  } catch (err) {
    next(err);
  }
};

exports.studentSummary = async (req, res, next) => {
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

exports.syncOffline = async (req, res, next) => {
  try {
    const { records } = req.body;
    const isSuperAdmin = req.user.role === 'super_admin'; // though unlikely for teacher
    const orgId = req.scope.organisationId || req.body.organisationId;
    
    const result = await attendanceService.syncOffline(req.user.id, records, orgId);
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

exports.listSessionsByMonth = async (req, res, next) => {
  try {
    const { month } = req.query; // Format YYYY-MM
    const isSuperAdmin = req.user.role === 'super_admin';
    const orgId = req.scope.organisationId || req.body.organisationId;
    
    const result = await attendanceService.getSessionsByMonth(req.user.id, month, orgId, isSuperAdmin);
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};
