import Student from '../models/Student.model.js';
import mongoose from 'mongoose';
import eventBus from './eventBus.service.js';
import { uploadImage, deleteImage } from './cloudinary.service.js';

const escapeRegExp = (value) => String(value).replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

/** Resolve the student for a scoped request; throws 404/403 on IDOR. */
const scopedStudent = async (studentId, scope) => {
  const query = { _id: studentId };
  if (scope && !scope.isSuperAdmin) query.organisation = scope.organisationId;
  const student = await Student.findOne(query);
  if (!student) throw Object.assign(new Error('Student not found'), { status: 404 });
  return student;
};

export const createStudent = async (fields, organisationId) => {
  const student = await Student.create({ ...fields, organisation: organisationId });
  return student;
};

export const getStudent = async (query) => {
  return Student.findOne(query).populate('course semester section');
};

export const updateStudent = async (query, fields) => {
  return Student.findOneAndUpdate(query, fields, { new: true }).populate('course semester section');
};

export const softDeleteStudent = async (query) => {
  return Student.findOneAndUpdate(query, { isActive: false }, { new: true });
};

export const bulkImport = async (studentsArray, organisationId, requesterId) => {
  const session = await mongoose.startSession();
  session.startTransaction();

  let succeeded = 0;
  let failed = 0;
  const errors = [];

  try {
    for (const data of studentsArray) {
      if (!data.rollNumber || !data.name || !data.course || !data.semester || !data.section) {
        failed++;
        errors.push({ rollNumber: data.rollNumber || 'UNKNOWN', error: 'Missing required fields' });
        continue;
      }

      const existing = await Student.findOne({ organisation: organisationId, rollNumber: data.rollNumber }).session(session);

      if (existing) {
        // Update-in-place strategy for repeated imports.
        existing.name = data.name;
        existing.course = data.course;
        existing.semester = data.semester;
        existing.section = data.section;
        if (data.email) existing.email = data.email;
        await existing.save({ session });
      } else {
        await Student.create([{
          ...data,
          organisation: organisationId
        }], { session });
      }
      succeeded++;
    }

    await session.commitTransaction();
    session.endSession();

    await eventBus.publish('students.imported', { organisationId, succeeded, failed, requesterId });
    return { total: studentsArray.length, succeeded, failed, errors };

  } catch (err) {
    await session.abortTransaction();
    session.endSession();
    throw err;
  }
};

export const listStudents = async (filters, organisationId, isSuperAdmin, page, limit) => {
  const query = {};
  if (!isSuperAdmin) query.organisation = organisationId;

  if (filters.course) query.course = filters.course;
  if (filters.semester) query.semester = filters.semester;
  if (filters.section) query.section = filters.section;
  if (filters.search) {
    // Escape the term: user input must never become live RegExp syntax.
    const safe = escapeRegExp(filters.search);
    query.$or = [
      { name: new RegExp(safe, 'i') },
      { rollNumber: new RegExp(safe, 'i') }
    ];
  }

  const skip = (page - 1) * limit;
  const [data, total] = await Promise.all([
    Student.find(query).skip(skip).limit(limit).populate('course semester section').sort('rollNumber'),
    Student.countDocuments(query),
  ]);

  return { data, total, page, limit };
};

export const uploadPhoto = async (studentId, fileBuffer, mimetype, scope) => {
  // IDOR guard: the student must exist within the requester's organisation
  // (previously ANY student in ANY org could be targeted by id).
  await scopedStudent(studentId, scope);
  const publicId = `students/${studentId}/photo`;
  const url = await uploadImage(fileBuffer, 'smartcampus/students', publicId);
  await Student.findByIdAndUpdate(studentId, { photo: url });
  return { url };
};

export const deletePhoto = async (studentId, scope) => {
  const student = await scopedStudent(studentId, scope);
  if (student.photo) {
    const publicId = `smartcampus/students/students/${studentId}/photo`;
    await deleteImage(publicId);
    student.photo = null;
    await student.save();
  }
  return { message: 'Photo deleted' };
};

export default { createStudent, getStudent, updateStudent, softDeleteStudent, bulkImport, listStudents, uploadPhoto, deletePhoto };
