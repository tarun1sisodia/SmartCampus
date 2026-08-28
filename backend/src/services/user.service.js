import User from '../models/User.model.js';
import AuditLog from '../models/AuditLog.model.js';
import bcrypt from 'bcrypt';
import { uploadImage, deleteImage } from './cloudinary.service.js';
import { revokeAllRefreshTokens } from './auth.service.js';

const PUBLIC_PROFILE_FIELDS = ['name', 'avatar', 'contact'];

export const listTeachers = async (organisationId, page, limit, isSuperAdmin) => {
  const query = { role: 'teacher' };
  if (!isSuperAdmin) {
    query.organisation = organisationId;
  }

  const skip = (page - 1) * limit;
  const data = await User.find(query).skip(skip).limit(limit).sort('name');
  const total = await User.countDocuments(query);

  return { data, total, page, limit };
};

/** Full user listing for the super-admin portal. */
export const listUsers = async ({ organisationId, role, page, limit, isSuperAdmin }) => {
  const query = {};
  if (!isSuperAdmin) query.organisation = organisationId;
  if (role) query.role = role;

  const skip = (page - 1) * limit;
  const [data, total] = await Promise.all([
    User.find(query).skip(skip).limit(limit).sort('-createdAt').populate('organisation', 'name'),
    User.countDocuments(query),
  ]);
  return { data, total, page, limit };
};

export const deactivateUser = async (userId, requesterOrgId, isSuperAdmin, requesterId) => {
  if (String(userId) === String(requesterId)) {
    throw Object.assign(new Error('You cannot deactivate your own account'), { status: 400 });
  }

  const user = await User.findById(userId);
  if (!user) throw Object.assign(new Error('User not found'), { status: 404 });

  if (!isSuperAdmin && String(user.organisation) !== String(requesterOrgId)) {
    throw Object.assign(new Error('Forbidden: Cannot deactivate a user outside your organisation'), { status: 403 });
  }

  // org_admins must not be able to take down another org_admin/super_admin.
  if (!isSuperAdmin && (user.role === 'org_admin' || user.role === 'super_admin')) {
    throw Object.assign(new Error('Forbidden: Insufficient role to deactivate this user'), { status: 403 });
  }

  user.isActive = false;
  await user.save();

  // Kill any live sessions immediately.
  await revokeAllRefreshTokens(user._id);

  await AuditLog.create({
    organisation: user.organisation,
    user: requesterId,
    action: 'DEACTIVATE_USER',
    entityType: 'User',
    entityId: user._id,
    newValues: { isActive: false }
  });

  return user;
};

export const updateUserRole = async (userId, role, requesterId, requesterOrgId, isSuperAdmin) => {
  if (!isSuperAdmin) {
    throw Object.assign(new Error('Only a super admin can change roles'), { status: 403 });
  }
  const user = await User.findById(userId);
  if (!user) throw Object.assign(new Error('User not found'), { status: 404 });

  const oldRole = user.role;
  user.role = role;
  await user.save();

  // Role changes invalidate existing sessions so stale role claims expire now.
  await revokeAllRefreshTokens(user._id);

  await AuditLog.create({
    organisation: user.organisation,
    user: requesterId,
    action: 'UPDATE_USER_ROLE',
    entityType: 'User',
    entityId: user._id,
    oldValues: { role: oldRole },
    newValues: { role },
  });

  return user;
};

export const changePassword = async (userId, oldPassword, newPassword) => {
  const user = await User.findById(userId).select('+password');
  if (!user) throw Object.assign(new Error('User not found'), { status: 404 });

  if (!(await bcrypt.compare(oldPassword, user.password))) {
    throw Object.assign(new Error('Current password is incorrect'), { status: 400 });
  }

  // Assign plaintext; the pre-save hook performs the single canonical hash.
  // (Hashing here used to double-hash and lock the user out.)
  user.password = newPassword;
  await user.save();

  // Invalidate every other session; the current device re-authenticates.
  await revokeAllRefreshTokens(user._id);

  await AuditLog.create({
    user: userId,
    action: 'CHANGE_PASSWORD',
    entityType: 'User',
    entityId: user._id,
  });

  return { message: 'Password changed. Please sign in again.' };
};

/** Admin-triggered password reset: queues a reset email to the user. */
export const adminResetPassword = async (userId, requesterId, requesterOrgId, isSuperAdmin) => {
  const user = await User.findById(userId);
  if (!user) throw Object.assign(new Error('User not found'), { status: 404 });
  if (!isSuperAdmin && String(user.organisation) !== String(requesterOrgId)) {
    throw Object.assign(new Error('Forbidden'), { status: 403 });
  }

  // Reuse the self-service flow: generates a hashed token, queues the email
  // and returns a uniform message (never reveals whether the email exists).
  const authService = await import('./auth.service.js');
  await authService.forgotPassword(user.email);

  await AuditLog.create({
    organisation: user.organisation,
    user: requesterId,
    action: 'ADMIN_TRIGGER_PASSWORD_RESET',
    entityType: 'User',
    entityId: user._id,
  });

  return { message: 'Password reset email sent' };
};

export const updateProfile = async (userId, payload) => {
  const updates = {};
  for (const field of PUBLIC_PROFILE_FIELDS) {
    if (payload[field] !== undefined) updates[field] = payload[field];
  }
  const user = await User.findByIdAndUpdate(userId, updates, { new: true }).populate('organisation', 'name');
  if (!user) throw Object.assign(new Error('User not found'), { status: 404 });
  return user;
};

export const uploadProfilePhoto = async (userId, fileBuffer, mimetype) => {
  const publicId = `users/${userId}/profile`;
  const url = await uploadImage(fileBuffer, 'smartcampus/profiles', publicId);
  await User.findByIdAndUpdate(userId, { avatar: url });
  return { url };
};

export const deleteProfilePhoto = async (userId) => {
  const user = await User.findById(userId);
  if (user && user.avatar) {
    const publicId = `smartcampus/profiles/users/${userId}/profile`;
    await deleteImage(publicId);
    user.avatar = null;
    await user.save();
  }
  return { message: 'Photo deleted' };
};

export default {
  listTeachers,
  listUsers,
  deactivateUser,
  updateUserRole,
  changePassword,
  adminResetPassword,
  updateProfile,
  uploadProfilePhoto,
  deleteProfilePhoto,
};
