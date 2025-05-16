import { Request, Response, NextFunction } from 'express';
import { ApiError } from '../utils/error';
import logger from '../utils/logger';
import ApiResponse from '../utils/response';

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  logger.error('Error caught by error handler:', {
    error: err,
    stack: err.stack,
    url: req.originalUrl,
    method: req.method,
    body: req.body
  });

  if (err instanceof ApiError) {
    return res.status(err.statusCode).json(
      ApiResponse.error(err.message, err.statusCode)
    );
  }

  // Handle Joi validation errors
  if (err.name === 'ValidationError') {
    return res.status(400).json(
      ApiResponse.error('Validation Error', 400, err)
    );
  }

  // Handle Supabase errors
  if (err.name === 'PostgrestError') {
    return res.status(400).json(
      ApiResponse.error('Database Error', 400, err)
    );
  }

  // Default error
  return res.status(500).json(
    ApiResponse.error('Internal Server Error', 500)
  );
};

export const notFound = (req: Request, res: Response, next: NextFunction) => {
  const error = new ApiError(404, `Route ${req.originalUrl} not found`);
  next(error);
};
