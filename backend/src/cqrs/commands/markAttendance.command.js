import attendanceService from '../../services/attendance.service.js';

export const handle = async (command) => {
  const { sessionId, attendanceArray, teacherId, organisationId, isSuperAdmin } = command;
  return await attendanceService.markBulk(sessionId, attendanceArray, teacherId, organisationId, isSuperAdmin);
};

export default { handle };
