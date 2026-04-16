import attendanceService from '../services/attendance.service.js';
import {  sendSuccess  } from '../utils/apiResponse.js';
import Session from '../models/Session.model.js';
import Attendance from '../models/Attendance.model.js';

export const createSession = async (req, res, next) => {
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

export const listSessions = async (req, res, next) => {
  try {
    const { date, subjectId, courseId, startDate, endDate } = req.query;
    const teacherId = req.user.id;
    const organisationId = req.scope?.organisationId;
    const isSuperAdmin = req.user.role === 'super_admin';

    const sessions = await attendanceService.listSessions(
      teacherId,
      organisationId,
      isSuperAdmin,
      { date, subjectId, courseId, startDate, endDate }
    );

    sendSuccess(res, sessions);
  } catch (err) {
    next(err);
  }
};

export const markBulk = async (req, res, next) => {
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
    const isSuperAdmin = req.user.role === 'super_admin'; // though unlikely for teacher
    const orgId = req.scope.organisationId || req.body.organisationId;
    
    const result = await attendanceService.syncOffline(req.user.id, records, orgId);
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export const listSessionsByMonth = async (req, res, next) => {
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

export default { createSession, listSessions, markBulk, getBySession, studentSummary, syncOffline, listSessionsByMonth };
