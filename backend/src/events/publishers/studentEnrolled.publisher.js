const eventBus = require('../../services/eventBus.service');

exports.publishStudentEnrolled = async (studentData) => {
  await eventBus.publish('student.enrolled', studentData);
};
