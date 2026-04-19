import authService from '../services/auth.service.js';
import {  sendSuccess  } from '../utils/apiResponse.js';

export const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const { accessToken, refreshToken, user } = await authService.login(email, password);

    // Set cookie (for web)
    res.cookie('refreshToken', refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict',
      maxAge: 7 * 24 * 60 * 60 * 1000
    });

    sendSuccess(res, { accessToken, refreshToken, user });
  } catch (err) {
    next(err);
  }
};

export const refresh = async (req, res, next) => {
  try {
    const token = req.cookies.refreshToken || req.body.refreshToken;
    if (!token) throw Object.assign(new Error('No refresh token'), { status: 401 });

    const { accessToken, refreshToken } = await authService.refreshAccessToken(token);

    res.cookie('refreshToken', refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict',
      maxAge: 7 * 24 * 60 * 60 * 1000
    });

    sendSuccess(res, { accessToken, refreshToken });
  } catch (err) {
    next(err);
  }
};

export const logout = async (req, res, next) => {
  try {
    const token = req.cookies.refreshToken || req.body.refreshToken;
    if (token) {
      await authService.logout(token);
    }
    res.clearCookie('refreshToken');
    sendSuccess(res, { message: 'Logged out successfully' });
  } catch (err) {
    next(err);
  }
};

export const registerSuperAdmin = async (req, res, next) => {
  try {
    // Only available during initial setup, usually handled by seed script
    sendSuccess(res, { message: 'Use seed script for super admin creation' });
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

export default { login, refresh, logout, registerSuperAdmin, forgotPassword, resetPassword };
