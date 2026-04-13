import logger from '../config/logger.js';
import {  Sentry  } from '../utils/sentry.js';

export default (err, req, res, next) => {
  Sentry.captureException(err);
  logger.error(`${err.message} - ${req.originalUrl} - ${req.method} - ${req.ip}`);

  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal Server Error',
    code: err.status || 500
  });
};
