import eventBus from '../../services/eventBus.service.js';

export const publishStudentEnrolled = async (studentData) => {
  await eventBus.publish('student.enrolled', studentData);
};

export default { publishStudentEnrolled };
