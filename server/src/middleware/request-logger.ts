import { Request, Response, NextFunction } from 'express';
import logger from '../utils/logger';

export const requestLogger = (req: Request, res: Response, next: NextFunction) => {
  // Generate request ID
  const requestId = Math.random().toString(36).substring(7);
  
  // Log request
  logger.info(`Incoming ${req.method} request to ${req.originalUrl}`, {
    requestId,
    method: req.method,
    url: req.originalUrl,
    ip: req.ip,
    userAgent: req.get('user-agent'),
    body: req.method !== 'GET' ? req.body : undefined
  });

  // Track response time
  const startTime = Date.now();

  // Override res.json to log response
  const originalJson = res.json;
  res.json = function(body: any) {
    const responseTime = Date.now() - startTime;
    
    logger.info(`Outgoing response for ${req.method} ${req.originalUrl}`, {
      requestId,
      statusCode: res.statusCode,
      responseTime: `${responseTime}ms`,
      body: process.env.NODE_ENV === 'development' ? body : undefined
    });

    return originalJson.call(this, body);
  };

  next();
};

export default requestLogger;
