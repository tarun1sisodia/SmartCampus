import { Request, Response, NextFunction } from 'express';
import { ApiError } from '../utils/error';
import logger from '../utils/logger';

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  if (err instanceof ApiError) {
    logger.error('API Error:', {
      statusCode: err.statusCode,
      message: err.message,
      stack: err.stack
    });

    return res.status(err.statusCode).json({
      status: err.status,
      message: err.message
    });
  }

  // Unexpected errors
  logger.error('Unexpected Error:', {
    error: err,
    stack: err.stack
  });

  return res.status(500).json({
    status: 'error',
    message: 'Internal server error'
  });
};

export const notFound = (req: Request, res: Response, next: NextFunction) => {
  const error = new ApiError(404, `Route ${req.originalUrl} not found`);
  next(error);
};
