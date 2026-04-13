import Queue from 'bull';
import redisClient from './redis.js';

const redisUrl = process.env.REDIS_URL || 'redis://localhost:6379';
const isTls = redisUrl.startsWith('rediss://');

const defaultOptions = {
  // Bull optionally takes a redis string or an object. 
  // For production Upstash/TLS, we pass the URL directly but ensure ioredis options are correct if needed.
  redis: redisUrl,
  ...(isTls && {
    settings: {
      lockDuration: 30000,
      stalledInterval: 30000,
      maxStalledCount: 1
    }
  }),
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
