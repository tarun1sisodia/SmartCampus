const eventBus = require('../../services/eventBus.service');

exports.publishAttendanceMarked = async (data) => {
  // data = { sessionId, studentId, newStatus, oldStatus }
  await eventBus.publish('attendance.marked', data);
};
