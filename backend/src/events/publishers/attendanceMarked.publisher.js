import eventBus from '../../services/eventBus.service.js';

export const publishAttendanceMarked = async (data) => {
  // data = { sessionId, studentId, newStatus, oldStatus }
  await eventBus.publish('attendance.marked', data);
};

export default { publishAttendanceMarked };
