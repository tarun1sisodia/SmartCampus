import Queue from 'bull';
import redisClient from './redis.js';

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
export const emailQueue = new Queue('emailQueue', defaultOptions);
export const backupQueue = new Queue('backupQueue', defaultOptions);
export const analyticsQueue = new Queue('analyticsQueue', defaultOptions);
