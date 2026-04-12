const eventBus = require('../../services/eventBus.service');
// Real implementation would safely require the CQRS view updater, avoiding cyclic dependencies:
// const { refreshAttendanceSummary } = require('../../cqrs/materializedViews/attendanceSummary.view');

exports.setup = () => {
  eventBus.registerHandler('attendance.marked', async (data) => {
    try {
      // Deferring require to avoid circular dependencies during initialization
      const { refreshAttendanceSummary } = require('../../cqrs/materializedViews/attendanceSummary.view');
      await refreshAttendanceSummary(data);
    } catch (err) {
      console.error('Failed to update analytics from event:', err);
    }
  });
};
