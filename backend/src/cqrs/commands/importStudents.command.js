const studentService = require('../../services/student.service');

exports.handle = async (command) => {
  const { studentsArray, organisationId, requesterId } = command;
  return await studentService.bulkImport(studentsArray, organisationId, requesterId);
};
