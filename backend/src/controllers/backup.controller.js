import backupService from '../services/backup.service.js';
import BackupRecord from '../models/BackupRecord.model.js';
import {  sendSuccess  } from '../utils/apiResponse.js';

export const create = async (req, res, next) => {
  try {
    const record = await backupService.createFullBackup(req.user.id, req.body.organisationId);
    sendSuccess(res, record, 201);
  } catch (err) {
    next(err);
  }
};

export const list = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const data = await BackupRecord.find().skip(skip).limit(limit).sort('-createdAt');
    const total = await BackupRecord.countDocuments();
    
    sendSuccess(res, { data, total, page, limit });
  } catch (err) {
    next(err);
  }
};

export const restore = async (req, res, next) => {
  try {
    // Restores are destructive and NOT implemented yet. Returning a fake
    // success here previously let an operator believe data had been restored.
    res.status(501).json({
      success: false,
      message: 'Backup restore is not implemented yet. Contact the platform team for manual restoration from S3.',
    });
  } catch (err) {
    next(err);
  }
};

export default { create, list, restore };
