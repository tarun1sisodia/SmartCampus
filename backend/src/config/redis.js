import Redis from 'ioredis';
import logger from './logger.js';

const urls = [process.env.REDIS_URL, process.env.REDIS_URL2].filter(Boolean);

// Dynamic Fallback Proxy for ioredis
// We wrap it heavily to switch endpoints under the hood if it repeatedly fails.
let currentUrlIndex = 0;

const redisClient = new Redis(urls[currentUrlIndex] || 'redis://localhost:6379', {
  maxRetriesPerRequest: null,
  enableReadyCheck: false,
  retryStrategy(times) {
    if (times >= 3 && urls.length > 1) {
      currentUrlIndex = (currentUrlIndex + 1) % urls.length;
      logger.warn(`Redis down. Failing over to endpoint: ${urls[currentUrlIndex]}`);
      
      // Forces ioredis to abandon the current hostname and connect to the fallback explicitly.
      // This is a known, robust mechanism for standalone cluster failovers without a Sentinel.
      const nextUri = new URL(urls[currentUrlIndex]);
      this.options.host = nextUri.hostname;
      this.options.port = parseInt(nextUri.port, 10) || 6379;
      this.options.tls = nextUri.protocol === 'rediss:' ? {} : undefined;
      
      return 500; // immediate retry on the new hostname
    }
    return Math.min(times * 100, 3000);
  }
});

redisClient.on('connect', () => {
  logger.info(`Redis connected successfully to active endpoint`);
});

redisClient.on('error', (err) => {
  logger.error(`Redis connection error: ${err.message}`);
});

export default redisClient;
