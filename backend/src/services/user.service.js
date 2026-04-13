import User from '../models/User.model.js';
import AuditLog from '../models/AuditLog.model.js';
import bcrypt from 'bcrypt';
import { uploadImage, deleteImage } from './cloudinary.service.js';

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

export const deactivateUser = async (userId, requesterOrgId, isSuperAdmin, requesterId) => {
  const user = await User.findById(userId);
  if (!user) throw new Error('User not found');

  if (!isSuperAdmin && String(user.organisation) !== String(requesterOrgId)) {
    throw new Error('Forbidden: Cannot deactivate a user outside your organisation');
  }

  user.isActive = false;
  await user.save();

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

export const changePassword = async (userId, oldPassword, newPassword) => {
  const user = await User.findById(userId).select('+password');
  if (!(await bcrypt.compare(oldPassword, user.password))) {
    throw new Error('Current password is incorrect');
  }
  user.password = await bcrypt.hash(newPassword, 10);
  await user.save();
  return { message: 'Password changed' };
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
    // Assuming Cloudinary public ID is derived or stored
    const publicId = `smartcampus/profiles/users/${userId}/profile`;
    await deleteImage(publicId);
    user.avatar = null;
    await user.save();
  }
  return { message: 'Photo deleted' };
};

export default { listTeachers, deactivateUser, changePassword, uploadProfilePhoto, deleteProfilePhoto };
