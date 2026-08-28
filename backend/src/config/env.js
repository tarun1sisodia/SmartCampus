import path from 'path';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment-specific .env file
const envFile = process.env.NODE_ENV ? `.env.${process.env.NODE_ENV}` : '.env';
dotenv.config({ path: path.join(__dirname, '../../', envFile) });

/**
 * Fail-fast validation of security-critical configuration.
 * The app must never boot in production with weak/default secrets,
 * because a leaked default renders JWT auth and QR verification useless.
 */
export function validateEnv() {
  const isProd = process.env.NODE_ENV === 'production';
  const errors = [];
  const warnings = [];

  const insecureDefaults = [
    'access-secret-key',
    'refresh-secret-key',
    'your-access-secret-key',
    'your-refresh-secret-key',
    'super_secret_attendance_salt',
    'changeme',
    'secret',
  ];

  const secretChecks = [
    { key: 'JWT_ACCESS_SECRET', min: 32 },
    { key: 'JWT_REFRESH_SECRET', min: 32 },
    { key: 'QR_SECRET_KEY', min: 24 },
  ];

  for (const { key, min } of secretChecks) {
    const value = process.env[key];
    if (!value) {
      if (isProd) errors.push(`${key} is required in production`);
      else warnings.push(`${key} is not set (development fallback will be used)`);
      continue;
    }
    if (value.length < min) {
      const msg = `${key} must be at least ${min} characters`;
      if (isProd) errors.push(msg);
      else warnings.push(msg);
    }
    if (insecureDefaults.includes(value.toLowerCase())) {
      const msg = `${key} is set to a known insecure default`;
      if (isProd) errors.push(msg);
      else warnings.push(msg);
    }
  }

  if (isProd) {
    if (process.env.FRONTEND_URL) {
      const origins = process.env.FRONTEND_URL.split(',').map((o) => o.trim()).filter(Boolean);
      if (origins.some((o) => o.startsWith('http://'))) {
        warnings.push('FRONTEND_URL contains http:// origins in production; use https://');
      }
    } else {
      warnings.push('FRONTEND_URL is not set; CORS will only allow same-origin requests');
    }
  }

  for (const w of warnings) console.warn(`[env] WARNING: ${w}`);
  if (errors.length > 0) {
    console.error('[env] FATAL: invalid environment configuration:');
    for (const e of errors) console.error(`[env]   - ${e}`);
    throw new Error(`Invalid environment configuration: ${errors.join('; ')}`);
  }
}

validateEnv();
