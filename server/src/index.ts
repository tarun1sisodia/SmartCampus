import express from 'express';
import cors from 'cors';
import rateLimit from 'express-rate-limit';
import helmet from 'helmet';
import compression from 'compression';
import config from './config/config';
import routes from './routes';
import { errorHandler, notFound } from './middleware/error-handler';
import requestLogger from './middleware/request-logger';
import logger from './utils/logger';

// Create Express app
const app = express();

// Security middleware
app.use(helmet());

// Enable CORS
app.use(cors());

// Compression
app.use(compression());

// Body parser
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Rate limiting
const limiter = rateLimit({
  windowMs: config.rateLimit.windowMs,
  max: config.rateLimit.maxRequests,
  message: 'Too many requests from this IP, please try again later.'
});
app.use(limiter);

// Request logging
app.use(requestLogger);

// Mount API routes
app.use('/api/v1', routes);

// Handle 404 routes
app.use(notFound);

// Error handling
app.use(errorHandler);

// Start server
const server = app.listen(config.server.port, () => {
  logger.info(`Server is running on port ${config.server.port} in ${config.server.nodeEnv} mode`);
  logger.info(`Health check available at: http://localhost:${config.server.port}/api/v1/health`);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err: Error) => {
  logger.error('Unhandled Promise Rejection:', err);
  // Close server & exit process
  server.close(() => {
    process.exit(1);
  });
});

// Handle uncaught exceptions
process.on('uncaughtException', (err: Error) => {
  logger.error('Uncaught Exception:', err);
  // Close server & exit process
  server.close(() => {
    process.exit(1);
  });
});

// Handle termination signals
process.on('SIGTERM', () => {
  logger.info('SIGTERM received. Shutting down gracefully...');
  server.close(() => {
    logger.info('Process terminated.');
  });
});

export default app;
