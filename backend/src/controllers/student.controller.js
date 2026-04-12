const studentService = require('../services/student.service');
const csvParser = require('../utils/csvParser');
const { sendSuccess } = require('../utils/apiResponse');
const Student = require('../models/Student.model');

exports.bulkImport = async (req, res, next) => {
  try {
    if (!req.file) throw Object.assign(new Error('No file uploaded'), { status: 400 });
    
    // We expect Multer to have saved it or parsed to buffer (if memory storage)
    // For disk storage, we read it
    const fs = require('fs');
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

exports.list = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const filters = {
      course: req.query.course,
      semester: req.query.semester,
      section: req.query.section,
      search: req.query.search
    };
    
    const isSuperAdmin = req.user.role === 'super_admin';
    const orgId = isSuperAdmin ? req.query.organisationId : req.scope.organisationId;
    
    const result = await studentService.listStudents(filters, orgId, isSuperAdmin, page, limit);
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

exports.create = async (req, res, next) => {
  try {
    const orgId = req.scope.organisationId || req.body.organisationId;
    const student = await Student.create({ ...req.body, organisation: orgId });
    sendSuccess(res, student, 201);
  } catch (err) {
    next(err);
  }
};

exports.getById = async (req, res, next) => {
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

exports.update = async (req, res, next) => {
  try {
    let q = { _id: req.params.id };
    if (!req.scope.isSuperAdmin) q.organisation = req.scope.organisationId;
    const student = await Student.findOneAndUpdate(q, req.body, { new: true });
    sendSuccess(res, student);
  } catch (err) {
    next(err);
  }
};

exports.delete = async (req, res, next) => {
  try {
    let q = { _id: req.params.id };
    if (!req.scope.isSuperAdmin) q.organisation = req.scope.organisationId;
    const student = await Student.findOneAndUpdate(q, { isActive: false }, { new: true });
    sendSuccess(res, { message: 'Deleted', _id: student?._id });
  } catch (err) {
    next(err);
  }
};
