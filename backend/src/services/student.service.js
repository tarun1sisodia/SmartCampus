const Student = require('../models/Student.model');
const mongoose = require('mongoose');
const eventBus = require('./eventBus.service');
const s3Client = require('../utils/s3.util');

exports.bulkImport = async (studentsArray, organisationId, requesterId) => {
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
        // Optional overwrite strategy; here we skip duplicates to be safe, or update them.
        existing.name = data.name;
        existing.course = data.course; // Assuming these are pre-mapped ObjectIds by CSV parser
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

exports.listStudents = async (filters, organisationId, isSuperAdmin, page, limit) => {
  const query = {};
  if (!isSuperAdmin) query.organisation = organisationId;
  
  if (filters.course) query.course = filters.course;
  if (filters.semester) query.semester = filters.semester;
  if (filters.section) query.section = filters.section;
  if (filters.search) {
    query.$or = [
      { name: new RegExp(filters.search, 'i') },
      { rollNumber: new RegExp(filters.search, 'i') }
    ];
  }

  // Ideally cache logic here matching REDIS strategy described
  const skip = (page - 1) * limit;
  const data = await Student.find(query).skip(skip).limit(limit).populate('course semester section').sort('rollNumber');
  const total = await Student.countDocuments(query);

  return { data, total, page, limit };
};

exports.uploadPhoto = async (studentId, fileBuffer, mimetype) => {
  const key = `students/${studentId}/photo-${Date.now()}.jpg`;
  const url = await s3Client.uploadFile(process.env.S3_PHOTO_BUCKET || 'smartcampus-photos', key, fileBuffer, mimetype);
  await Student.findByIdAndUpdate(studentId, { photo: url });
  return { url };
};

exports.deletePhoto = async (studentId) => {
  const student = await Student.findById(studentId);
  if (student && student.photo) {
    const keyMatch = student.photo.match(/amazonaws\.com\/(.+)$/);
    if (keyMatch) {
      await s3Client.deleteFile(process.env.S3_PHOTO_BUCKET || 'smartcampus-photos', keyMatch[1]);
    }
    student.photo = null;
    await student.save();
  }
  return { message: 'Photo deleted' };
};
