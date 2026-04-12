const attendanceService = require('../../services/attendance.service');

exports.handle = async (query) => {
  const { studentId, organisationId, isSuperAdmin, semesterId } = query;
  return await attendanceService.getStudentSummary(studentId, organisationId, isSuperAdmin, semesterId);
};
