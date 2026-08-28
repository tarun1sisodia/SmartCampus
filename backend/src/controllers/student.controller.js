import studentService from '../services/student.service.js';
import csvParser from '../utils/csvParser.js';
import { sendSuccess } from '../utils/apiResponse.js';
import Session from '../models/Session.model.js';

/** Escape user input before embedding into a RegExp (prevents ReDoS/injection). */
const escapeRegExp = (value) => String(value).replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

/** Whitelist of client-settable student fields (prevents mass assignment). */
const STUDENT_FIELDS = ['rollNumber', 'name', 'email', 'course', 'semester', 'section', 'enrollmentYear', 'contact', 'parentContact', 'address'];

const pickStudentFields = (body) => {
  const payload = {};
  for (const field of STUDENT_FIELDS) {
    if (body[field] !== undefined) payload[field] = body[field];
  }
  return payload;
};

export const bulkImport = async (req, res, next) => {
  try {
    if (!req.file) throw Object.assign(new Error('No file uploaded'), { status: 400 });

    const buffer = req.file.buffer || (req.file.path ? (await import('fs')).readFileSync(req.file.path) : null);
    if (!buffer) throw Object.assign(new Error('File could not be read'), { status: 400 });

    const parsedData = await csvParser.parseCSV(buffer);
    const result = await studentService.bulkImport(parsedData, req.scope.organisationId || req.body.organisationId, req.user.id);

    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export const list = async (req, res, next) => {
  try {
    const page = Math.max(parseInt(req.query.page) || 1, 1);
    const limit = Math.min(Math.max(parseInt(req.query.limit) || 10, 1), 100);
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
    const orgId = req.user.role === 'super_admin' ? req.body.organisationId : req.scope.organisationId;
    if (!orgId) throw Object.assign(new Error('Organisation ID required'), { status: 400 });
    const student = await studentService.createStudent(pickStudentFields(req.body), orgId);
    sendSuccess(res, student, 201);
  } catch (err) {
    next(err);
  }
};

export const getById = async (req, res, next) => {
  try {
    let q = { _id: req.params.id };
    if (!req.scope.isSuperAdmin) q.organisation = req.scope.organisationId;
    const student = await studentService.getStudent(q);
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
    const student = await studentService.updateStudent(q, pickStudentFields(req.body));
    if (!student) throw Object.assign(new Error('Not found'), { status: 404 });
    sendSuccess(res, student);
  } catch (err) {
    next(err);
  }
};

export const deleteFn = async (req, res, next) => {
  try {
    let q = { _id: req.params.id };
    if (!req.scope.isSuperAdmin) q.organisation = req.scope.organisationId;
    const student = await studentService.softDeleteStudent(q);
    if (!student) throw Object.assign(new Error('Not found'), { status: 404 });
    sendSuccess(res, { message: 'Deleted', _id: student._id });
  } catch (err) {
    next(err);
  }
};

export const uploadPhoto = async (req, res, next) => {
  try {
    if (!req.file) throw Object.assign(new Error('No photo uploaded'), { status: 400 });
    const result = await studentService.uploadPhoto(
      req.params.id,
      req.file.buffer,
      req.file.mimetype,
      req.scope,
    );
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export const deletePhoto = async (req, res, next) => {
  try {
    const result = await studentService.deletePhoto(req.params.id, req.scope);
    sendSuccess(res, result);
  } catch (err) {
    next(err);
  }
};

export { escapeRegExp };

export default { bulkImport, list, create, getById, update, delete: deleteFn, uploadPhoto, deletePhoto };
