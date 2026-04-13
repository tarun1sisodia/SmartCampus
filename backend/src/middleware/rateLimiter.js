import rateLimit from 'express-rate-limit';
import RedisStore from 'rate-limit-redis';
import redisClient from '../config/redis.js';

export const strictLimiter = rateLimit({
  store: new RedisStore({ 
    sendCommand: (...args) => redisClient.call(...args) 
  }),
  windowMs: 15 * 60 * 1000,
  max: 5, // 5 requests per 15 minutes
  keyGenerator: (req) => req.user?.id || req.ip || 'global',
  message: { success: false, message: 'Too many requests, please try again later.' }
});

export const standardLimiter = rateLimit({
  store: new RedisStore({ 
    sendCommand: (...args) => redisClient.call(...args) 
  }),
  windowMs: 15 * 60 * 1000,
  max: 100, // 100 requests per 15 min
  keyGenerator: (req) => req.user?.id || req.ip || 'global',
  message: { success: false, message: 'Rate limit exceeded.' }
});

export default { strictLimiter, standardLimiter };
