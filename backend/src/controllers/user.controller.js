import crypto from 'crypto';
import userService from '../services/user.service.js';
import invitationService from '../services/invitation.service.js';
import emailService from '../services/email.service.js';
import {  sendSuccess  } from '../utils/apiResponse.js';
import User from '../models/User.model.js';

export const listTeachers = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const isSuperAdmin = req.user.role === 'super_admin';
    
    const result = await userService.listTeachers(req.scope.organisationId, page, limit, isSuperAdmin);
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export const deactivate = async (req, res, next) => {
  try {
    const isSuperAdmin = req.user.role === 'super_admin';
    const result = await userService.deactivateUser(
      req.params.userId, 
      req.scope.organisationId, 
      isSuperAdmin,
      req.user.id
    );
    sendSuccess(res, { message: 'User deactivated', _id: result._id });
  } catch (err) {
    next(err);
  }
};

// Invitation specific routes mapped into users router in spec
export const sendInvite = async (req, res, next) => {
  try {
    const { email, role, name } = req.body;
    // Assuming you can only invite within your own organisation unless super admin
    const orgId = req.scope.organisationId || req.body.organisationId;
    if (!orgId) throw Object.assign(new Error('Organisation ID required'), { status: 400 });

    const user = await invitationService.createInvite(req.user.id, email, role, orgId, name);
    sendSuccess(res, { message: 'Invitation sent', userId: user._id });
  } catch (err) {
    next(err);
  }
};

export const acceptInvite = async (req, res, next) => {
  try {
    const { token, password, name } = req.body;
    const result = await invitationService.acceptInvite(token, password, name);
    
    res.cookie('refreshToken', result.tokens.refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict',
      maxAge: 7 * 24 * 60 * 60 * 1000
    });

    sendSuccess(res, { accessToken: result.tokens.accessToken, user: result.user });
  } catch (err) {
    next(err);
  }
};

export const resendInvite = async (req, res, next) => {
  try {
    // Requires User fetch to resend
    const userToresend = await User.findById(req.params.userId);
    if (!userToresend || userToresend.isActive) throw new Error('User not pending invitation');
    
    const result = await invitationService.createInvite(
      req.user.id, 
      userToresend.email, 
      userToresend.role, 
      userToresend.organisation, 
      userToresend.name
    );
    sendSuccess(res, { message: 'Invitation resent' });
  } catch (err) {
    next(err);
  }
};

export const list = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const filters = { role: req.query.role };

    const result = await userService.listUsers(filters, page, limit);
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export const update = async (req, res, next) => {
  try {
    const user = await userService.updateUser(req.params.userId, req.body);
    sendSuccess(res, user);
  } catch (err) {
    next(err);
  }
};

export const resetPassword = async (req, res, next) => {
  try {
    const user = await userService.resetPasswordToken(req.params.userId);
    const resetToken = crypto.randomBytes(32).toString('hex');
    user.resetPasswordToken = resetToken;
    user.resetPasswordExpires = Date.now() + 3600000; // 1 hour
    await user.save();
    await emailService.sendPasswordResetEmail(user.email, resetToken);
    sendSuccess(res, { message: 'Password reset email sent' });
  } catch (err) {
    next(err);
  }
};

export const updateProfile = async (req, res, next) => {
  try {
    const allowed = {};
    if (req.body.name) allowed.name = req.body.name;
    if (req.body.email) allowed.email = req.body.email;
    if (req.body.avatar || req.body.photoUrl || req.body.avatarUrl) {
      allowed.avatar = req.body.avatar || req.body.photoUrl || req.body.avatarUrl;
    }
    if (req.body.contact) allowed.contact = req.body.contact;

    if (Object.keys(allowed).length === 0) {
      const error = new Error('No editable fields provided');
      error.status = 400;
      throw error;
    }

    const user = await User.findByIdAndUpdate(req.user.id, allowed, { new: true });
    if (!user) {
      const error = new Error('User not found');
      error.status = 404;
      throw error;
    }
    sendSuccess(res, { user });
  } catch (err) {
    next(err);
  }
};

export const changePassword = async (req, res, next) => {
  try {
    const { oldPassword, newPassword } = req.body;
    const result = await userService.changePassword(req.user.id, oldPassword, newPassword);
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export const uploadProfilePhoto = async (req, res, next) => {
  try {
    if (!req.file) throw new Error('No photo uploaded');
    const result = await userService.uploadProfilePhoto(req.user.id, req.file.buffer, req.file.mimetype);
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export const deleteProfilePhoto = async (req, res, next) => {
  try {
    const result = await userService.deleteProfilePhoto(req.user.id);
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export const getMe = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id).populate('organisation');
    sendSuccess(res, { user });
  } catch (err) {
    next(err);
  }
};

export default { list, update, resetPassword, updateProfile, listTeachers, deactivate, sendInvite, acceptInvite, resendInvite, changePassword, uploadProfilePhoto, deleteProfilePhoto, getMe };
