const User = require('../models/User.model');
const RefreshToken = require('../models/RefreshToken.model');
const { comparePassword } = require('../utils/hashPassword');
const { generateAccessToken, generateRefreshToken } = require('../utils/generateToken');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');

const REFRESH_TOKEN_SECRET = process.env.JWT_REFRESH_SECRET || 'refresh-secret-key';

exports.login = async (email, password) => {
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

exports.refreshAccessToken = async (oldRefreshToken) => {
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

exports.logout = async (refreshToken) => {
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
