import studentService from '../../services/student.service.js';

export const handle = async (command) => {
  const { studentsArray, organisationId, requesterId } = command;
  return await studentService.bulkImport(studentsArray, organisationId, requesterId);
};

export default { handle };
