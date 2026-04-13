import orgService from '../services/organisation.service.js';
import {  sendSuccess  } from '../utils/apiResponse.js';
import Organisation from '../models/Organisation.model.js';

export const create = async (req, res, next) => {
  try {
    const org = await orgService.createOrganisation(req.body, req.user.id);
    sendSuccess(res, org, 201);
  } catch (err) {
    next(err);
  }
};

export const list = async (req, res, next) => {
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
    if (req.body.status === 'suspended') {
      const org = await orgService.suspendOrganisation(req.params.orgId);
      return sendSuccess(res, org);
    }
    
    // Normal update operations
    const org = await Organisation.findByIdAndUpdate(req.params.orgId, req.body, { new: true });
    sendSuccess(res, org);
  } catch (err) {
    next(err);
  }
};

export default { create, list, get, update };
