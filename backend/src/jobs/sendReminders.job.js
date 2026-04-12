const { analyticsQueue } = require('../config/bull');

exports.setupSendReminders = () => {
  analyticsQueue.process('send-reminders', async (job) => {
    // Placeholder logic for sending reminders
    // console.log("Sending weekly low-attendance reminders to parents...");
  });

  analyticsQueue.add('send-reminders', {}, { repeat: { cron: '0 8 * * 1' } });
};
