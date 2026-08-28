import Organisation from '../models/Organisation.model.js';
import { sendSuccess } from '../utils/apiResponse.js';

/** Whitelisted, client-settable organisation fields (prevents mass assignment
 *  of status/createdBy/subscription directly through the update endpoint). */
const ORG_FIELDS = ['name', 'type', 'domain', 'address', 'contactEmail', 'contactPhone'];
const SUBSCRIPTION_FIELDS = ['plan', 'validUntil', 'maxTeachers', 'maxStudents'];

const pickOrgFields = (body) => {
  const payload = {};
  for (const field of ORG_FIELDS) {
    if (body[field] !== undefined) payload[field] = body[field];
  }
  if (body.subscription && typeof body.subscription === 'object') {
    payload.subscription = {};
    for (const field of SUBSCRIPTION_FIELDS) {
      if (body.subscription[field] !== undefined) payload.subscription[field] = body.subscription[field];
    }
  }
  return payload;
};

export const create = async (req, res, next) => {
  try {
    const payload = pickOrgFields(req.body);
    payload.createdBy = req.user.id; // never trust client-supplied createdBy
    const org = await Organisation.create(payload);
    sendSuccess(res, org, 201);
  } catch (err) {
    next(err);
  }
};

export const list = async (req, res, next) => {
  try {
    const page = Math.max(parseInt(req.query.page) || 1, 1);
    const limit = Math.min(Math.max(parseInt(req.query.limit) || 10, 1), 100);
    const filters = { status: req.query.status, type: req.query.type };

    const query = {};
    if (filters.status) query.status = filters.status;
    if (filters.type) query.type = filters.type;

    const skip = (page - 1) * limit;
    const [data, total] = await Promise.all([
      Organisation.find(query).skip(skip).limit(limit).sort('-createdAt'),
      Organisation.countDocuments(query),
    ]);
    sendSuccess(res, { data, total, page, limit });
  } catch (err) {
    next(err);
  }
};

export const get = async (req, res, next) => {
  try {
    const org = await Organisation.findById(req.params.orgId);
    if (!org) throw Object.assign(new Error('Not found'), { status: 404 });
    sendSuccess(res, org);
  } catch (err) {
    next(err);
  }
};

export const update = async (req, res, next) => {
  try {
    // Suspension is the only direct status change; it also deactivates all
    // users of the org so a suspended tenant cannot keep operating.
    if (req.body.status === 'suspended') {
      const org = await Organisation.findById(req.params.orgId);
      if (!org) throw Object.assign(new Error('Not found'), { status: 404 });

      org.status = 'suspended';
      await org.save();

      const User = (await import('../models/User.model.js')).default;
      await User.updateMany({ organisation: org._id, role: { $ne: 'super_admin' } }, { isActive: false });

      return sendSuccess(res, org);
    }

    if (req.body.status === 'active') {
      const org = await Organisation.findById(req.params.orgId);
      if (!org) throw Object.assign(new Error('Not found'), { status: 404 });
      org.status = 'active';
      await org.save();
      return sendSuccess(res, org);
    }

    const org = await Organisation.findByIdAndUpdate(
      req.params.orgId,
      pickOrgFields(req.body),
      { new: true, runValidators: true }
    );
    if (!org) throw Object.assign(new Error('Not found'), { status: 404 });
    sendSuccess(res, org);
  } catch (err) {
    next(err);
  }
};

export default { create, list, get, update };
