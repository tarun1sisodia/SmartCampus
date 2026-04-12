const jwt = require('jsonwebtoken');

const ACCESS_TOKEN_SECRET = process.env.JWT_ACCESS_SECRET || 'access-secret-key';
const REFRESH_TOKEN_SECRET = process.env.JWT_REFRESH_SECRET || 'refresh-secret-key';

exports.generateAccessToken = (user) => {
  const payload = { 
    sub: user._id, 
    role: user.role, 
    org: user.organisation 
  };
  return jwt.sign(payload, ACCESS_TOKEN_SECRET, { expiresIn: '15m' });
};

exports.generateRefreshToken = (user) => {
  const payload = { sub: user._id };
  return jwt.sign(payload, REFRESH_TOKEN_SECRET, { expiresIn: '7d' });
};
