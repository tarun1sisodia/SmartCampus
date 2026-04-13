import analyticsService from '../services/analytics.service.js';
import {  sendSuccess  } from '../utils/apiResponse.js';
import AttendanceSummary from '../models/AttendanceSummary.model.js';
import Session from '../models/Session.model.js';

export const classReport = async (req, res, next) => {
  try {
    const isSuperAdmin = req.user.role === 'super_admin';
    const { semester, section } = req.query;
    
    const result = await analyticsService.getClassAttendance(
      req.params.courseId,
      semester,
      section,
      req.scope.organisationId,
      isSuperAdmin
    );
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export const studentTrend = async (req, res, next) => {
  try {
    const isSuperAdmin = req.user.role === 'super_admin';
    const query = { student: req.params.studentId };
    if (!isSuperAdmin) query.organisation = req.scope.organisationId;

    const trends = await AttendanceSummary.find(query).sort('date -1').limit(30);
    sendSuccess(res, trends);
  } catch (err) {
    next(err);
  }
};

export const teacherPerformance = async (req, res, next) => {
  try {
    const isSuperAdmin = req.user.role === 'super_admin';
    const { startDate, endDate } = req.query;
    const teacherId = req.params.teacherId;
    
    const result = await analyticsService.getTeacherPerformance(
      teacherId,
      startDate,
      endDate,
      req.scope.organisationId,
      isSuperAdmin
    );
    
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export default { classReport, studentTrend, teacherPerformance };
