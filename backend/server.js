import { fileURLToPath } from 'url';
import { dirname } from 'path';
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

import './src/config/env.js'; // MUST be the very first import to populate process.env safely

import app from './src/app.js';
import connectDB from './src/config/database.js';
import logger from './src/config/logger.js';
import {  initSocket  } from './src/socket/index.js';

// Subscriptions & background routines
import updateAnalyticsSubscriber from './src/events/subscribers/updateAnalytics.subscriber.js';
import sendNotificationSubscriber from './src/events/subscribers/sendNotification.subscriber.js';
import {  setupDailyBackup  } from './src/jobs/dailyBackup.job.js';
import {  setupSendReminders  } from './src/jobs/sendReminders.job.js';

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

  initSocket(server);

  process.on('SIGTERM', () => {
    logger.info('SIGTERM received. Shutting down gracefully.');
    server.close(() => {
      logger.info('Process terminated.');
      process.exit(0);
    });
  });
};

startServer();
