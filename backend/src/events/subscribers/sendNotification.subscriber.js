const eventBus = require('../../services/eventBus.service');

exports.setup = () => {
  eventBus.registerHandler('attendance.marked', async (data) => {
    const { newStatus, oldStatus, studentId } = data;
    if (oldStatus === 'absent' && newStatus === 'present') {
      // Mock push notification or SMS logic
      // console.log(`Sending notification to parents of student ${studentId}: Marked present.`);
    }
  });
};
