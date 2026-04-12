const rateLimit = require('express-rate-limit');
const RedisStore = require('rate-limit-redis').default;
const redisClient = require('../config/redis');

exports.strictLimiter = rateLimit({
  store: new RedisStore({ 
    sendCommand: (...args) => redisClient.call(...args) 
  }),
  windowMs: 15 * 60 * 1000,
  max: 5, // 5 requests per 15 minutes
  keyGenerator: (req) => req.user?.id || req.ip || 'global',
  message: { success: false, message: 'Too many requests, please try again later.' }
});

exports.standardLimiter = rateLimit({
  store: new RedisStore({ 
    sendCommand: (...args) => redisClient.call(...args) 
  }),
  windowMs: 15 * 60 * 1000,
  max: 100, // 100 requests per 15 min
  keyGenerator: (req) => req.user?.id || req.ip || 'global',
  message: { success: false, message: 'Rate limit exceeded.' }
});
