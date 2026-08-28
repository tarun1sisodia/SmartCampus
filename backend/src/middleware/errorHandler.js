import logger from '../config/logger.js';
import { Sentry } from '../utils/sentry.js';

const isProd = process.env.NODE_ENV === 'production';

const STATUS_MESSAGES = {
  400: 'Bad request',
  401: 'Unauthorized',
  403: 'Forbidden',
  404: 'Not found',
  409: 'Conflict',
  413: 'Payload too large',
  429: 'Too many requests',
};

export default (err, req, res, next) => {
  const status = err.status || 500;

  if (status >= 500) {
    Sentry.captureException(err);
    // Log full detail server-side only.
    logger.error(`${err.message} - ${req.originalUrl} - ${req.method} - ${req.ip} - reqId=${req.id}\n${err.stack}`);
  }

  const message =
    status >= 500
      ? (isProd ? 'Internal Server Error' : err.message || 'Internal Server Error')
      : (err.message || STATUS_MESSAGES[status] || 'Request failed');

  res.status(status).json({
    success: false,
    message,
    requestId: req.id,
    code: status,
  });
};
