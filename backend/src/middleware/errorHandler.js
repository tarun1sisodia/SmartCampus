const logger = require('../config/logger');
const { Sentry } = require('../utils/sentry');

module.exports = (err, req, res, next) => {
  Sentry.captureException(err);
  logger.error(`${err.message} - ${req.originalUrl} - ${req.method} - ${req.ip}`);

  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal Server Error',
    code: err.status || 500
  });
};
