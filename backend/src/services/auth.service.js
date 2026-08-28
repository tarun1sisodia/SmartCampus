import User from '../models/User.model.js';
import RefreshToken from '../models/RefreshToken.model.js';
import { comparePassword } from '../utils/hashPassword.js';
import {
  generateAccessToken,
  generateRefreshToken,
  verifyRefreshToken,
} from '../utils/generateToken.js';
import crypto from 'crypto';
import emailService from './email.service.js';
import logger from '../config/logger.js';

const REFRESH_TOKEN_TTL_DAYS = 7;

/** Refresh/reset/invite tokens are stored hashed (sha256) so a DB leak
 *  cannot be replayed, and lookups are O(1) instead of a bcrypt loop. */
export const hashToken = (token) =>
  crypto.createHash('sha256').update(token).digest('hex');

const refreshExpiry = () => {
  const d = new Date();
  d.setDate(d.getDate() + REFRESH_TOKEN_TTL_DAYS);
  return d;
};

export const revokeAllRefreshTokens = async (userId) => {
  await RefreshToken.deleteMany({ user: userId });
};

export const login = async (email, password) => {
  const normalizedEmail = String(email || '').trim().toLowerCase();
  const user = await User.findOne({ email: normalizedEmail, isActive: true }).select('+password');
  if (!user) throw new AuthError('Invalid credentials', 401);

  const isMatch = await comparePassword(password, user.password);
  if (!isMatch) throw new AuthError('Invalid credentials', 401);

  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);

  await RefreshToken.create({
    tokenHash: hashToken(refreshToken),
    user: user._id,
    expiresAt: refreshExpiry(),
  });

  user.lastLogin = new Date();
  await user.save();

  const userObj = user.toJSON();
  return { accessToken, refreshToken, user: userObj };
};

export const refreshAccessToken = async (oldRefreshToken) => {
  // 1. Verify signature first (cheap) before touching the DB.
  let decoded;
  try {
    decoded = verifyRefreshToken(oldRefreshToken);
  } catch (err) {
    throw new AuthError('Refresh token invalid or expired', 401);
  }
  if (!decoded?.sub) throw new AuthError('Refresh token invalid', 401);

  // 2. O(1) lookup of the stored hash.
  const tokenHash = hashToken(oldRefreshToken);
  const stored = await RefreshToken.findOne({ tokenHash });
  const user = await User.findById(decoded.sub);

  if (!user || (!user.isActive && user.role !== 'super_admin')) {
    throw new AuthError('User inactive', 401);
  }

  if (!stored) {
    // Signature is valid but the token was never issued (or was already
    // rotated/revoked) => treat as token theft and revoke every session.
    logger.warn(`Refresh token reuse detected for user ${decoded.sub}; revoking all sessions`);
    await revokeAllRefreshTokens(user._id);
    throw new AuthError('Refresh token invalid', 401);
  }

  if (stored.expiresAt < new Date()) {
    await stored.deleteOne();
    throw new AuthError('Refresh token expired', 401);
  }

  // 3. Rotate: replace stored hash, return fresh pair.
  const newAccessToken = generateAccessToken(user);
  const newRefreshToken = generateRefreshToken(user);
  stored.tokenHash = hashToken(newRefreshToken);
  stored.expiresAt = refreshExpiry();
  await stored.save();

  return { accessToken: newAccessToken, refreshToken: newRefreshToken };
};

export const logout = async (refreshToken) => {
  if (!refreshToken) return;
  try {
    const decoded = verifyRefreshToken(refreshToken);
    await RefreshToken.deleteOne({ tokenHash: hashToken(refreshToken), user: decoded.sub });
  } catch (_) {
    // Invalid/expired token — nothing to revoke.
  }
};

export const forgotPassword = async (email) => {
  // Uniform response regardless of account existence to prevent enumeration.
  const genericMessage = 'If an account exists for this email, a reset link has been sent';

  const normalizedEmail = String(email || '').trim().toLowerCase();
  const user = await User.findOne({ email: normalizedEmail, isActive: true });
  if (!user) return { message: genericMessage };

  const resetToken = crypto.randomBytes(32).toString('hex');
  // Store only the hash; the raw token only ever lives in the email link.
  user.resetPasswordToken = hashToken(resetToken);
  user.resetPasswordExpires = Date.now() + 60 * 60 * 1000; // 1 hour
  await user.save();

  await emailService.sendPasswordResetEmail(user.email, resetToken);
  return { message: genericMessage };
};

export const resetPassword = async (token, newPassword) => {
  if (!token) throw new AuthError('Invalid or expired token', 400);
  const user = await User.findOne({
    resetPasswordToken: hashToken(token),
    resetPasswordExpires: { $gt: Date.now() },
  });
  if (!user) throw new AuthError('Invalid or expired token', 400);

  // Assign the PLAINTEXT password: the User pre-save hook performs the
  // single canonical bcrypt hash (assigning a pre-hashed value here used to
  // double-hash and permanently lock the account out).
  user.password = newPassword;
  user.resetPasswordToken = undefined;
  user.resetPasswordExpires = undefined;
  await user.save();

  // Any stolen session dies immediately after a password reset.
  await revokeAllRefreshTokens(user._id);

  return { message: 'Password updated' };
};

export default {
  login,
  refreshAccessToken,
  logout,
  forgotPassword,
  resetPassword,
  revokeAllRefreshTokens,
  hashToken,
};

/** Minimal error carrying an HTTP status, understood by the global handler. */
export class AuthError extends Error {
  constructor(message, status = 400) {
    super(message);
    this.status = status;
  }
}
