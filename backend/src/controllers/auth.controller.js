import authService from '../services/auth.service.js';
import { sendSuccess } from '../utils/apiResponse.js';

const REFRESH_COOKIE_OPTIONS = {
  httpOnly: true,
  secure: process.env.NODE_ENV === 'production',
  sameSite: 'strict',
  path: '/api/v1/auth', // cookie is only needed for the auth endpoints
  maxAge: 7 * 24 * 60 * 60 * 1000
};

export const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const { accessToken, refreshToken, user } = await authService.login(email, password);

    res.cookie('refreshToken', refreshToken, REFRESH_COOKIE_OPTIONS);

    sendSuccess(res, { accessToken, refreshToken, user });
  } catch (err) {
    next(err);
  }
};

export const refresh = async (req, res, next) => {
  try {
    const token = req.cookies?.refreshToken || req.body?.refreshToken;
    if (!token) throw Object.assign(new Error('No refresh token'), { status: 401 });

    const { accessToken, refreshToken } = await authService.refreshAccessToken(token);

    res.cookie('refreshToken', refreshToken, REFRESH_COOKIE_OPTIONS);

    sendSuccess(res, { accessToken, refreshToken });
  } catch (err) {
    next(err);
  }
};

export const logout = async (req, res, next) => {
  try {
    const token = req.cookies?.refreshToken || req.body?.refreshToken;
    if (token) {
      await authService.logout(token);
    }
    res.clearCookie('refreshToken', { path: '/api/v1/auth' });
    sendSuccess(res, { message: 'Logged out successfully' });
  } catch (err) {
    next(err);
  }
};

export const forgotPassword = async (req, res, next) => {
  try {
    const { email } = req.body;
    const result = await authService.forgotPassword(email);
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export const resetPassword = async (req, res, next) => {
  try {
    const { token, newPassword } = req.body;
    const result = await authService.resetPassword(token, newPassword);
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export default { login, refresh, logout, forgotPassword, resetPassword };
