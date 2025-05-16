import dotenv from 'dotenv';
import path from 'path';

// Load environment variables from .env file
dotenv.config({ path: path.join(__dirname, '../../.env') });

interface Config {
  server: {
    port: number;
    nodeEnv: string;
  };
  supabase: {
    url: string;
    anonKey: string;
    serviceRoleKey: string;
  };
  jwt: {
    secret: string;
    expiresIn: string;
  };
  rateLimit: {
    windowMs: number;
    maxRequests: number;
  };
  logging: {
    level: string;
  };
}

const isDevelopment = process.env.NODE_ENV === 'development';

// Validate and get environment variables
function validateConfig(): Config {
  // In development, allow missing Supabase config
  if (isDevelopment) {
    if (!process.env.SUPABASE_URL || !process.env.SUPABASE_SERVICE_ROLE_KEY) {
      console.warn('Warning: Supabase configuration missing. Some features will be unavailable.');
    }
  } else {
    // In production, require Supabase config
    const requiredEnvVars = [
      'PORT',
      'NODE_ENV',
      'SUPABASE_URL',
      'SUPABASE_ANON_KEY',
      'SUPABASE_SERVICE_ROLE_KEY',
      'JWT_SECRET'
    ];

    for (const envVar of requiredEnvVars) {
      if (!process.env[envVar]) {
        throw new Error(`Missing required environment variable: ${envVar}`);
      }
    }
  }

  return {
    server: {
      port: parseInt(process.env.PORT || '3000', 10),
      nodeEnv: process.env.NODE_ENV || 'development',
    },
    supabase: {
      url: process.env.SUPABASE_URL || 'http://localhost:54321',  // Default Supabase local development URL
      anonKey: process.env.SUPABASE_ANON_KEY || '',
      serviceRoleKey: process.env.SUPABASE_SERVICE_ROLE_KEY || '',
    },
    jwt: {
      secret: process.env.JWT_SECRET || 'local-development-secret',
      expiresIn: process.env.JWT_EXPIRES_IN || '24h',
    },
    rateLimit: {
      windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000', 10),
      maxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10),
    },
    logging: {
      level: process.env.LOG_LEVEL || 'info',
    },
  };
}

const config: Config = validateConfig();

export default config;
