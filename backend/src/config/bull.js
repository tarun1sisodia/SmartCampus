import Queue from 'bull';
import Redis from 'ioredis';
import redisClient from './redis.js';  // your existing redis client (if any)

const redisUrl = process.env.REDIS_URL || 'redis://localhost:6379';
const isTls = redisUrl.startsWith('rediss://');

// Create a custom Redis client with reconnection strategy
const customRedisClient = new Redis(redisUrl, {
  maxRetriesPerRequest: null,          // prevents Bull from crashing on retry exhaustion
  enableReadyCheck: false,
  reconnectOnError: (err) => {
    console.warn('Redis reconnect on error:', err.message);
    return true;                       // always try to reconnect
  },
  retryStrategy: (times) => {
    if (times > 10) {
      console.error('Redis connection failed after 10 retries, giving up');
      return null;                     // stop retrying
    }
    return Math.min(times * 100, 3000); // exponential backoff, max 3s
  }
});

// Factory function for Bull to use the same client for all connections
const createClient = (type) => {
  if (type === 'client') return customRedisClient;
  if (type === 'subscriber') return customRedisClient.duplicate();
  return customRedisClient.duplicate();
};

const defaultOptions = {
  createClient,
  defaultJobOptions: {
    attempts: 3,
    backoff: { type: 'exponential', delay: 1000 },
    removeOnComplete: true,
    timeout: 30000,    // 30 second job timeout
  }
};

// Create Specific Queues
export const emailQueue = new Queue('emailQueue', defaultOptions);
export const backupQueue = new Queue('backupQueue', defaultOptions);
export const analyticsQueue = new Queue('analyticsQueue', defaultOptions);