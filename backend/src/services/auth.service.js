import User from '../models/User.model.js';
import RefreshToken from '../models/RefreshToken.model.js';
import {  comparePassword  } from '../utils/hashPassword.js';
import {  generateAccessToken, generateRefreshToken  } from '../utils/generateToken.js';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import crypto from 'crypto';
import emailService from './email.service.js';

const REFRESH_TOKEN_SECRET = process.env.JWT_REFRESH_SECRET || 'refresh-secret-key';

export const login = async (email, password) => {
  const user = await User.findOne({ email, isActive: true }).select('+password');
  if (!user) throw new Error('Invalid credentials');

  const isMatch = await comparePassword(password, user.password);
  if (!isMatch) throw new Error('Invalid credentials');

  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);

  const hashedRefreshToken = await bcrypt.hash(refreshToken, 10);
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 7);

  await RefreshToken.create({
    token: hashedRefreshToken,
    user: user._id,
    expiresAt
  });

  user.lastLogin = new Date();
  await user.save();

  const userObj = user.toJSON();
  return { accessToken, refreshToken, user: userObj };
};

export const refreshAccessToken = async (oldRefreshToken) => {
  const decoded = jwt.decode(oldRefreshToken);
  if (!decoded || !decoded.sub) throw new Error('Invalid refresh token');

  const tokens = await RefreshToken.find({ user: decoded.sub });
  let matchedTokenDoc = null;

  for (let doc of tokens) {
    if (await bcrypt.compare(oldRefreshToken, doc.token)) {
      matchedTokenDoc = doc;
      break;
    }
  }

  if (!matchedTokenDoc) throw new Error('Refresh token not found or invalid');
  if (matchedTokenDoc.expiresAt < new Date()) throw new Error('Refresh token expired');

  try {
    jwt.verify(oldRefreshToken, REFRESH_TOKEN_SECRET);
  } catch (err) {
    throw new Error('Refresh token invalid signature');
  }

  const user = await User.findById(decoded.sub);
  if (!user || (!user.isActive && user.role !== 'super_admin')) throw new Error('User inactive');

  const newAccessToken = generateAccessToken(user);
  const newRefreshToken = generateRefreshToken(user);

  const newHashedRefresh = await bcrypt.hash(newRefreshToken, 10);
  matchedTokenDoc.token = newHashedRefresh;
  const newExpiresAt = new Date();
  newExpiresAt.setDate(newExpiresAt.getDate() + 7);
  matchedTokenDoc.expiresAt = newExpiresAt;
  await matchedTokenDoc.save();

  return { accessToken: newAccessToken, refreshToken: newRefreshToken };
};

export const logout = async (refreshToken) => {
  const decoded = jwt.decode(refreshToken);
  if (!decoded || !decoded.sub) return;

  const tokens = await RefreshToken.find({ user: decoded.sub });
  for (let doc of tokens) {
    if (await bcrypt.compare(refreshToken, doc.token)) {
      await RefreshToken.findByIdAndDelete(doc._id);
      break;
    }
  }
};

export const forgotPassword = async (email) => {
  const user = await User.findOne({ email, isActive: true });
  if (!user) throw new Error('No user found with this email');
  const resetToken = crypto.randomBytes(32).toString('hex');
  user.resetPasswordToken = resetToken;
  user.resetPasswordExpires = Date.now() + 3600000; // 1 hour
  await user.save();
  await emailService.sendPasswordResetEmail(user.email, resetToken);
  return { message: 'Reset link sent' };
};

export const resetPassword = async (token, newPassword) => {
  const user = await User.findOne({
    resetPasswordToken: token,
    resetPasswordExpires: { $gt: Date.now() }
  });
  if (!user) throw new Error('Invalid or expired token');
  user.password = await bcrypt.hash(newPassword, 10);
  user.resetPasswordToken = null;
  user.resetPasswordExpires = null;
  await user.save();
  return { message: 'Password updated' };
};

export default { login, refreshAccessToken, logout, forgotPassword, resetPassword };
