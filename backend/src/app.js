import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import morgan from 'morgan';
import cookieParser from 'cookie-parser';
import requestId from './middleware/requestId.js';
import errorHandler from './middleware/errorHandler.js';
import { standardLimiter } from './middleware/rateLimiter.js';
import routes from './routes/v1/index.js';
import logger from './config/logger.js';
import swaggerJsDoc from 'swagger-jsdoc';
import swaggerUi from 'swagger-ui-express';

const isProd = process.env.NODE_ENV === 'production';

const swaggerOptions = {
  swaggerDefinition: {
    openapi: '3.0.0',
    info: {
      title: 'SmartCampus API',
      version: '1.0.0',
      description: 'SmartCampus Backend Infrastructure API',
    },
    servers: [{ url: 'http://localhost:5000' }],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        }
      }
    },
    security: [{ bearerAuth: [] }]
  },
  apis: ['./src/routes/v1/*.js'],
};

const swaggerDocs = swaggerJsDoc(swaggerOptions);

const app = express();

// Behind load balancers/proxies (needed for correct req.ip in rate limiting).
app.set('trust proxy', 1);

app.use(helmet());
app.use(cors({
  // Accept multiple origins via FRONTEND_URL (comma separated) and always
  // allow local dev portals.
  origin(origin, callback) {
    const allowed = [
      'http://localhost:3000',
      'http://localhost:3001',
      ...(process.env.FRONTEND_URL ? process.env.FRONTEND_URL.split(',').map((o) => o.trim()) : []),
    ].filter(Boolean);

    // Allow non-browser clients (mobile apps) that send no Origin header.
    if (!origin || allowed.includes(origin)) return callback(null, true);
    return callback(null, false);
  },
  credentials: true
}));

app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true, limit: '1mb' }));
app.use(cookieParser());

// HTTP access logs (skip health checks; pipe through winston in production).
morgan.token('id', (req) => req.id);
const morganFormat = isProd ? ':id :remote-addr :method :url :status :response-time ms' : 'combined';
app.use(morgan(morganFormat, {
  skip: (req) => req.originalUrl.startsWith('/api/v1/health'),
  stream: isProd ? { write: (line) => logger.http?.(line.trim()) ?? logger.info(line.trim()) } : undefined,
}));

app.use(requestId);

// API Routes (global budget + per-route limiters inside)
app.use('/api/v1', standardLimiter, routes);

// Interactive API docs are a dev/staging tool; never expose them in prod.
if (!isProd) {
  app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocs));
}

// 404 Handler
app.use((req, res, next) => {
  res.status(404).json({ success: false, message: 'Resource not found' });
});

// Global Error Handler
app.use(errorHandler);

export default app;
