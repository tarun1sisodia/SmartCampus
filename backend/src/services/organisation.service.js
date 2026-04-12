const Organisation = require('../models/Organisation.model');

exports.createOrganisation = async (data, superAdminId) => {
  if (data.domain) {
    const existing = await Organisation.findOne({ domain: data.domain });
    if (existing) throw new Error('Organisation with this domain already exists');
  }

  data.createdBy = superAdminId;
  return await Organisation.create(data);
};

exports.listOrganisations = async (filters, page, limit) => {
  const query = {};
  if (filters.status) query.status = filters.status;
  if (filters.type) query.type = filters.type;

  const skip = (page - 1) * limit;
  const data = await Organisation.find(query).skip(skip).limit(limit).sort('-createdAt');
  const total = await Organisation.countDocuments(query);

  return { data, total, page, limit };
};

exports.suspendOrganisation = async (orgId) => {
  const org = await Organisation.findById(orgId);
  if (!org) throw new Error('Organisation not found');

  org.status = 'suspended';
  await org.save();

  // Could also deactivate all users in that organisation
  // const User = require('../models/User.model');
  // await User.updateMany({ organisation: orgId }, { isActive: false });

  return org;
};
