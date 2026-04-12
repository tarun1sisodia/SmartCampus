const orgService = require('../services/organisation.service');
const { sendSuccess } = require('../utils/apiResponse');

exports.create = async (req, res, next) => {
  try {
    const org = await orgService.createOrganisation(req.body, req.user.id);
    sendSuccess(res, org, 201);
  } catch (err) {
    next(err);
  }
};

exports.list = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const filters = { status: req.query.status, type: req.query.type };
    
    const result = await orgService.listOrganisations(filters, page, limit);
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

exports.get = async (req, res, next) => {
  try {
    const org = await require('../models/Organisation.model').findById(req.params.orgId);
    if (!org) throw Object.assign(new Error('Not found'), { status: 404 });
    sendSuccess(res, org);
  } catch (err) {
    next(err);
  }
};

exports.update = async (req, res, next) => {
  try {
    if (req.body.status === 'suspended') {
      const org = await orgService.suspendOrganisation(req.params.orgId);
      return sendSuccess(res, org);
    }
    
    // Normal update operations
    const Organisation = require('../models/Organisation.model');
    const org = await Organisation.findByIdAndUpdate(req.params.orgId, req.body, { new: true });
    sendSuccess(res, org);
  } catch (err) {
    next(err);
  }
};
