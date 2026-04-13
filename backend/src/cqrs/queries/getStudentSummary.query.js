import attendanceService from '../../services/attendance.service.js';

export const handle = async (query) => {
  const { studentId, organisationId, isSuperAdmin, semesterId } = query;
  return await attendanceService.getStudentSummary(studentId, organisationId, isSuperAdmin, semesterId);
};

export default { handle };
