import jwt from 'jsonwebtoken';

/**
 * Secrets are validated at boot by src/config/env.js (validateEnv).
 * In production a missing/weak secret aborts startup; the fallbacks below
 * only ever apply to local development.
 */
const isProd = process.env.NODE_ENV === 'production';

const ACCESS_TOKEN_SECRET = process.env.JWT_ACCESS_SECRET || (isProd ? undefined : 'dev-access-secret-please-override');
const REFRESH_TOKEN_SECRET = process.env.JWT_REFRESH_SECRET || (isProd ? undefined : 'dev-refresh-secret-please-override');

if (isProd && (!ACCESS_TOKEN_SECRET || !REFRESH_TOKEN_SECRET)) {
  throw new Error('JWT secrets must be configured in production');
}

const ACCESS_TOKEN_TTL = process.env.JWT_ACCESS_TTL || '15m';
const REFRESH_TOKEN_TTL_SECONDS = 7 * 24 * 60 * 60; // 7 days

export const generateAccessToken = (user) => {
  const payload = {
    sub: user._id,
    role: user.role,
    org: user.organisation,
  };
  return jwt.sign(payload, ACCESS_TOKEN_SECRET, { expiresIn: ACCESS_TOKEN_TTL });
};

export const generateRefreshToken = (user) => {
  const payload = { sub: user._id };
  return jwt.sign(payload, REFRESH_TOKEN_SECRET, {
    expiresIn: REFRESH_TOKEN_TTL_SECONDS,
  });
};

export const verifyRefreshToken = (token) => jwt.verify(token, REFRESH_TOKEN_SECRET);

export const verifyAccessToken = (token) => jwt.verify(token, ACCESS_TOKEN_SECRET);

export default { generateAccessToken, generateRefreshToken, verifyRefreshToken, verifyAccessToken };
