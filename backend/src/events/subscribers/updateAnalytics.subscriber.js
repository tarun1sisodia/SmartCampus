import eventBus from '../../services/eventBus.service.js';
// Real implementation would safely require the CQRS view updater, avoiding cyclic dependencies:
// import {  refreshAttendanceSummary  } from '../../cqrs/materializedViews/attendanceSummary.view.js';

export const setup = () => {
  eventBus.registerHandler('attendance.marked', async (data) => {
    try {
      // Deferring require to avoid circular dependencies during initialization
      const module = await import('../../cqrs/materializedViews/attendanceSummary.view.js');
      await module.refreshAttendanceSummary(data);
    } catch (err) {
      console.error('Failed to update analytics from event:', err);
    }
  });
};

export default { setup };
