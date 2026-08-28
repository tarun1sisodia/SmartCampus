import jwt from 'jsonwebtoken';
import { verifyAccessToken } from '../utils/generateToken.js';

/**
 * Bearer-token authentication middleware.
 * Secrets are validated at boot; no insecure fallback is allowed here.
 */
export default (req, res, next) => {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) {
    return res.status(401).json({ success: false, message: 'No token provided' });
  }

  try {
    const decoded = verifyAccessToken(token);
    req.user = {
      id: decoded.sub,
      role: decoded.role,
      organisation: decoded.org,
    };
    next();
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Invalid or expired token' });
  }
};
