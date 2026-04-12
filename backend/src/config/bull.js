const Queue = require('bull');
const redisClient = require('./redis');

const defaultOptions = {
  redis: process.env.REDIS_URL || 'redis://localhost:6379',
  defaultJobOptions: {
    attempts: 3,
    backoff: {
      type: 'exponential',
      delay: 1000
    },
    removeOnComplete: true,
  }
};

// Create Specific Queues
const emailQueue = new Queue('emailQueue', defaultOptions);
const backupQueue = new Queue('backupQueue', defaultOptions);
const analyticsQueue = new Queue('analyticsQueue', defaultOptions);

module.exports = {
  emailQueue,
  backupQueue,
  analyticsQueue
};
