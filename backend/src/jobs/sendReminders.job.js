import {  analyticsQueue  } from '../config/bull.js';

export const setupSendReminders = () => {
  analyticsQueue.process('send-reminders', async (job) => {
    // Placeholder logic for sending reminders
    // console.log("Sending weekly low-attendance reminders to parents...");
  });

  analyticsQueue.add('send-reminders', {}, { repeat: { cron: '0 8 * * 1' } });
};

export default { setupSendReminders };
