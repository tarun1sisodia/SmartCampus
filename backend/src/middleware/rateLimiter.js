import rateLimit from 'express-rate-limit';
import RedisStore from 'rate-limit-redis';
import redisClient from '../config/redis.js';

/**
 * Rate limiters.
 *
 * - Keyed by IP (rate limiting happens before auth, so req.user is absent).
 * - `trust proxy` is enabled in app.js so req.ip reflects the real client
 *   behind load balancers.
 * - Fail-open: if Redis is temporarily unreachable the store returns
 *   zeroed replies (shape-matched per command) instead of erroring every
 *   request — availability wins over rate limiting accuracy.
 */
const failOpenReply = (command) => {
  const name = String(command[0] || '').toUpperCase();
  if (name === 'SCRIPT') return 'failopen'; // SCRIPT LOAD expects a string sha
  if (name.startsWith('EVAL') || name.startsWith('INCR')) return ['0', '0']; // [hits, ttl]
  return [0];
};

const makeStore = () =>
  new RedisStore({
    sendCommand: async (...args) => {
      // Only pass through when Redis is actually ready: ioredis queues
      // commands issued in any other state (maxRetriesPerRequest:null makes
      // that queue forever) which would hang the request.
      if (redisClient.status !== 'ready') {
        return failOpenReply(args);
      }
      try {
        return await redisClient.call(...args);
      } catch (err) {
        return failOpenReply(args);
      }
    },
  });

const build = ({ windowMs, max, message }) =>
  rateLimit({
    store: makeStore(),
    windowMs,
    max,
    standardHeaders: true,
    legacyHeaders: false,
    keyGenerator: (req) => req.ip || 'global',
    message: { success: false, message },
  });

/** Login, password reset and other credential endpoints. */
export const strictLimiter = build({
  windowMs: 15 * 60 * 1000,
  max: 10,
  message: 'Too many attempts, please try again later.',
});

/** Token refresh / invite acceptance / password change. */
export const sensitiveLimiter = build({
  windowMs: 15 * 60 * 1000,
  max: 30,
  message: 'Too many requests, please slow down.',
});

/** Default API budget. */
export const standardLimiter = build({
  windowMs: 15 * 60 * 1000,
  max: 300,
  message: 'Rate limit exceeded.',
});

export default { strictLimiter, sensitiveLimiter, standardLimiter };
