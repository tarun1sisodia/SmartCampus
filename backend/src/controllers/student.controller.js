import studentService from '../services/student.service.js';
import csvParser from '../utils/csvParser.js';
import {  sendSuccess  } from '../utils/apiResponse.js';
import Student from '../models/Student.model.js';
import Session from '../models/Session.model.js';
import fs from 'fs';

export const bulkImport = async (req, res, next) => {
  try {
    if (!req.file) throw Object.assign(new Error('No file uploaded'), { status: 400 });
    
    // We expect Multer to have saved it or parsed to buffer (if memory storage)
    // For disk storage, we read it
    const buffer = fs.readFileSync(req.file.path);
    
    const parsedData = await csvParser.parseCSV(buffer);
    
    const result = await studentService.bulkImport(parsedData, req.scope.organisationId || req.body.organisationId, req.user.id);
    
    // Cleanup temporary file
    fs.unlinkSync(req.file.path);
    
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export const list = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const filters = {
      course: req.query.course,
      semester: req.query.semester,
      section: req.query.section,
      search: req.query.search
    };

    if (req.query.sessionId) {
      const session = await Session.findById(req.query.sessionId);
      if (session) {
        filters.course = session.course;
        filters.semester = session.semester;
        filters.section = session.section;
      }
    }
    
    const isSuperAdmin = req.user.role === 'super_admin';
    const orgId = isSuperAdmin ? req.query.organisationId : req.scope.organisationId;
    
    const result = await studentService.listStudents(filters, orgId, isSuperAdmin, page, limit);
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export const create = async (req, res, next) => {
  try {
    const orgId = req.scope.organisationId || req.body.organisationId;
    const student = await Student.create({ ...req.body, organisation: orgId });
    sendSuccess(res, student, 201);
  } catch (err) {
    next(err);
  }
};

export const getById = async (req, res, next) => {
  try {
    let q = { _id: req.params.id };
    if (!req.scope.isSuperAdmin) q.organisation = req.scope.organisationId;
    const student = await Student.findOne(q).populate('course semester section');
    if (!student) throw Object.assign(new Error('Not found'), { status: 404 });
    sendSuccess(res, student);
  } catch (err) {
    next(err);
  }
};

export const update = async (req, res, next) => {
  try {
    let q = { _id: req.params.id };
    if (!req.scope.isSuperAdmin) q.organisation = req.scope.organisationId;
    const student = await Student.findOneAndUpdate(q, req.body, { new: true });
    sendSuccess(res, student);
  } catch (err) {
    next(err);
  }
};

export const deleteFn = async (req, res, next) => {
  try {
    let q = { _id: req.params.id };
    if (!req.scope.isSuperAdmin) q.organisation = req.scope.organisationId;
    const student = await Student.findOneAndUpdate(q, { isActive: false }, { new: true });
    sendSuccess(res, { message: 'Deleted', _id: student?._id });
  } catch (err) {
    next(err);
  }
};

export const uploadPhoto = async (req, res, next) => {
  try {
    if (!req.file) throw new Error('No photo uploaded');
    const result = await studentService.uploadPhoto(req.params.id, req.file.buffer, req.file.mimetype);
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export const deletePhoto = async (req, res, next) => {
  try {
    const result = await studentService.deletePhoto(req.params.id);
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export default { bulkImport, list, create, getById, update, delete: deleteFn, uploadPhoto, deletePhoto };
