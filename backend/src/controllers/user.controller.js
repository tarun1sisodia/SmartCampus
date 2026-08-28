import userService from '../services/user.service.js';
import invitationService from '../services/invitation.service.js';
import { sendSuccess } from '../utils/apiResponse.js';
import User from '../models/User.model.js';

export const listTeachers = async (req, res, next) => {
  try {
    const page = Math.max(parseInt(req.query.page) || 1, 1);
    const limit = Math.min(Math.max(parseInt(req.query.limit) || 10, 1), 100);
    const isSuperAdmin = req.user.role === 'super_admin';

    const result = await userService.listTeachers(req.scope.organisationId, page, limit, isSuperAdmin);
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

/** Paginated listing of all users (super-admin portal). */
export const listUsers = async (req, res, next) => {
  try {
    const page = Math.max(parseInt(req.query.page) || 1, 1);
    const limit = Math.min(Math.max(parseInt(req.query.limit) || 10, 1), 100);
    const result = await userService.listUsers({
      organisationId: req.scope.organisationId,
      role: req.query.role,
      page,
      limit,
      isSuperAdmin: req.user.role === 'super_admin',
    });
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export const updateUserRole = async (req, res, next) => {
  try {
    const result = await userService.updateUserRole(
      req.params.userId,
      req.body.role,
      req.user.id,
      req.scope.organisationId,
      req.user.role === 'super_admin'
    );
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
    // Non-super-admins are always pinned to their own organisation by
    // orgScope; only super_admin may target another organisation.
    const orgId = req.user.role === 'super_admin' ? req.body.organisationId : req.scope.organisationId;
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
      path: '/api/v1/auth',
      maxAge: 7 * 24 * 60 * 60 * 1000
    });

    sendSuccess(res, { accessToken: result.tokens.accessToken, user: result.user });
  } catch (err) {
    next(err);
  }
};

export const resendInvite = async (req, res, next) => {
  try {
    const userToResend = await User.findById(req.params.userId);
    if (!userToResend || userToResend.isActive) {
      throw Object.assign(new Error('User not pending invitation'), { status: 404 });
    }

    // Tenant isolation: only super_admin or admins of the same organisation
    // may re-issue an invite (was previously cross-org IDOR).
    const isSuperAdmin = req.user.role === 'super_admin';
    if (!isSuperAdmin && String(userToResend.organisation) !== String(req.scope.organisationId)) {
      throw Object.assign(new Error('Forbidden'), { status: 403 });
    }
    // Role guard mirrors createInvite so the resend cannot escalate roles.
    const result = await invitationService.createInvite(
      req.user.id,
      userToResend.email,
      userToResend.role,
      userToResend.organisation,
      userToResend.name
    );
    sendSuccess(res, { message: 'Invitation resent' });
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

export const adminResetPassword = async (req, res, next) => {
  try {
    const result = await userService.adminResetPassword(
      req.params.userId,
      req.user.id,
      req.scope.organisationId,
      req.user.role === 'super_admin'
    );
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export const uploadProfilePhoto = async (req, res, next) => {
  try {
    if (!req.file) throw Object.assign(new Error('No photo uploaded'), { status: 400 });
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
    const user = await User.findById(req.user.id).populate('organisation', 'name status subscription type');
    if (!user) throw Object.assign(new Error('User not found'), { status: 404 });
    sendSuccess(res, { user });
  } catch (err) {
    next(err);
  }
};

export const updateMe = async (req, res, next) => {
  try {
    const user = await userService.updateProfile(req.user.id, req.body);
    sendSuccess(res, { user });
  } catch (err) {
    next(err);
  }
};

export default {
  listTeachers,
  listUsers,
  updateUserRole,
  deactivate,
  sendInvite,
  acceptInvite,
  resendInvite,
  changePassword,
  adminResetPassword,
  uploadProfilePhoto,
  deleteProfilePhoto,
  getMe,
  updateMe,
};
