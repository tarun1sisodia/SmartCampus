const userService = require('../services/user.service');
const invitationService = require('../services/invitation.service');
const { sendSuccess } = require('../utils/apiResponse');

exports.listTeachers = async (req, res, next) => {
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

exports.deactivate = async (req, res, next) => {
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
exports.sendInvite = async (req, res, next) => {
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

exports.acceptInvite = async (req, res, next) => {
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

exports.resendInvite = async (req, res, next) => {
  try {
    // Requires User fetch to resend
    const User = require('../models/User.model');
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

exports.changePassword = async (req, res, next) => {
  try {
    const { oldPassword, newPassword } = req.body;
    const result = await userService.changePassword(req.user.id, oldPassword, newPassword);
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

exports.uploadProfilePhoto = async (req, res, next) => {
  try {
    if (!req.file) throw new Error('No photo uploaded');
    const result = await userService.uploadProfilePhoto(req.user.id, req.file.buffer, req.file.mimetype);
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

exports.deleteProfilePhoto = async (req, res, next) => {
  try {
    const result = await userService.deleteProfilePhoto(req.user.id);
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};
