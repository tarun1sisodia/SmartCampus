const analyticsService = require('../services/analytics.service');
const { sendSuccess } = require('../utils/apiResponse');
const AttendanceSummary = require('../models/AttendanceSummary.model');
const Session = require('../models/Session.model');

exports.classReport = async (req, res, next) => {
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

exports.studentTrend = async (req, res, next) => {
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

exports.teacherPerformance = async (req, res, next) => {
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
