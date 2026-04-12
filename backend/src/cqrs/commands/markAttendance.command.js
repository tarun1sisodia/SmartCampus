const attendanceService = require('../../services/attendance.service');

exports.handle = async (command) => {
  const { sessionId, attendanceArray, teacherId, organisationId, isSuperAdmin } = command;
  return await attendanceService.markBulk(sessionId, attendanceArray, teacherId, organisationId, isSuperAdmin);
};
