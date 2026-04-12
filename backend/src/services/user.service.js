const User = require('../models/User.model');
const AuditLog = require('../models/AuditLog.model');

exports.listTeachers = async (organisationId, page, limit, isSuperAdmin) => {
  const query = { role: 'teacher' };
  if (!isSuperAdmin) {
    query.organisation = organisationId;
  }

  const skip = (page - 1) * limit;
  const data = await User.find(query).skip(skip).limit(limit).sort('name');
  const total = await User.countDocuments(query);

  return { data, total, page, limit };
};

exports.deactivateUser = async (userId, requesterOrgId, isSuperAdmin, requesterId) => {
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
