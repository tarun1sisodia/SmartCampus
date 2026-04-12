require('dotenv').config();
const app = require('./src/app');
const connectDB = require('./src/config/database');
const logger = require('./src/config/logger');

// Subscriptions & background routines
const updateAnalyticsSubscriber = require('./src/events/subscribers/updateAnalytics.subscriber');
const sendNotificationSubscriber = require('./src/events/subscribers/sendNotification.subscriber');
const { setupDailyBackup } = require('./src/jobs/dailyBackup.job');
const { setupSendReminders } = require('./src/jobs/sendReminders.job');

const PORT = process.env.PORT || 5000;

const startServer = async () => {
  await connectDB();

  updateAnalyticsSubscriber.setup();
  sendNotificationSubscriber.setup();
  
  setupDailyBackup();
  setupSendReminders();

  const server = app.listen(PORT, () => {
    logger.info(`Server running in ${process.env.NODE_ENV || 'development'} mode on port ${PORT}`);
  });

  process.on('SIGTERM', () => {
    logger.info('SIGTERM received. Shutting down gracefully.');
    server.close(() => {
      logger.info('Process terminated.');
      process.exit(0);
    });
  });
};

startServer();
