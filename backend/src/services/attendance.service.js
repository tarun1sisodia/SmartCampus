import Session from '../models/Session.model.js';
import AttendanceSummary from '../models/AttendanceSummary.model.js';
import Attendance from '../models/Attendance.model.js';
import Student from '../models/Student.model.js';
import Subject from '../models/Subject.model.js';
import Course from '../models/Course.model.js';
import Semester from '../models/Semester.model.js';
import Section from '../models/Section.model.js';
import User from '../models/User.model.js';
import eventBus from './eventBus.service.js';

export const markBulk = async (sessionId, attendanceArray, teaciherId, organisationId, isSuperAdmin) => {
  const session = await Session.findById(sessionId);
  if (!session) throw new Error('Session not found');

  if (!isSuperAdmin && String(session.organisation) !== String(organisationId)) {
    throw new Error('Forbidden: Session belongs to another organisation');
  }

  let updatedCount = 0;

  for (const item of attendanceArray) {
    const studentExists = await Student.findOne({ _id: item.studentId, organisation: session.organisation });
    if (!studentExists) continue;

    const existingAttendance = await Attendance.findOne({ session: sessionId, student: item.studentId });
    const oldStatus = existingAttendance ? existingAttendance.status : null;

    if (existingAttendance) {
      existingAttendance.status = item.status;
      existingAttendance.markedBy = teacherId;
      existingAttendance.remarks = item.remarks || existingAttendance.remarks;
      existingAttendance.timestamp = new Date();
      await existingAttendance.save();
    } else {
      await Attendance.create({
        session: sessionId,
        student: item.studentId,
        status: item.status,
        markedBy: teacherId,
        remarks: item.remarks,
        organisation: session.organisation
      });
    }

    await eventBus.publish('attendance.marked', {
      sessionId,
      studentId: item.studentId,
      newStatus: item.status,
      oldStatus
    });

    updatedCount++;
  }

  return { updatedCount };
};

export const getStudentSummary = async (studentId, organisationId, isSuperAdmin, semesterId) => {
  // Simple fallback logic since actual caching or full aggregation is specific for CQRS
  const query = { student: studentId };
  if (!isSuperAdmin) query.organisation = organisationId;
  if (semesterId) query.semester = semesterId;

  const result = await AttendanceSummary.aggregate([
    { $match: query },
    { $group: { _id: "$status", count: { $sum: 1 } } }
  ]);

  let total = 0;
  let present = 0;
  result.forEach(r => {
    total += r.count;
    if (r._id === 'present' || r._id === 'late') present += r.count; // assuming 'late' is counted as present for %
  });

  return { result, total, percentage: total > 0 ? (present / total) * 100 : 0 };
};

export const syncOffline = async (teacherId, offlineRecords, organisationId) => {
  const results = [];
  for (const record of offlineRecords) {
    try {
      // Check if session exists and belongs to teacher
      const session = await Session.findOne({ _id: record.sessionId, teacher: teacherId });
      if (!session) throw new Error('Session not found');
      
      // Check if attendance already exists (last write wins by timestamp)
      const existing = await Attendance.findOne({ session: record.sessionId, student: record.studentId });
      if (existing && existing.timestamp > new Date(record.timestamp)) {
        results.push({ studentId: record.studentId, status: 'skipped', reason: 'Server has newer data' });
        continue;
      }
      
      // Upsert
      await Attendance.findOneAndUpdate(
        { session: record.sessionId, student: record.studentId },
        { status: record.status, markedBy: teacherId, timestamp: new Date(record.timestamp), remarks: record.remarks, organisation: organisationId },
        { upsert: true }
      );
      results.push({ studentId: record.studentId, status: record.status, synced: true });
    } catch (err) {
      results.push({ studentId: record.studentId, error: err.message });
    }
  }
  return results;
};

export const listSessions = async (teacherId, organisationId, isSuperAdmin, filters = {}) => {
  const { date, subjectId, courseId, startDate, endDate } = filters;

  const query = { teacher: teacherId };
  if (!isSuperAdmin) query.organisation = organisationId;

  // Date filtering
  if (date === 'today') {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);
    query.date = { $gte: today, $lt: tomorrow };
  } else if (date && !isNaN(Date.parse(date))) {
    const parsed = new Date(date);
    parsed.setHours(0, 0, 0, 0);
    const nextDay = new Date(parsed);
    nextDay.setDate(nextDay.getDate() + 1);
    query.date = { $gte: parsed, $lt: nextDay };
  } else if (startDate || endDate) {
    query.date = {};
    if (startDate) query.date.$gte = new Date(startDate);
    if (endDate) query.date.$lte = new Date(endDate);
  }

  if (subjectId) query.subject = subjectId;
  if (courseId) query.course = courseId;

  return await Session.find(query)
    .populate('subject course semester section teacher', 'name code title')
    .sort({ date: 1, startTime: 1 });
};

export const getSessionsByMonth = async (teacherId, yearMonth, organisationId, isSuperAdmin) => {
  const [year, month] = yearMonth.split('-');
  const start = new Date(year, month - 1, 1);
  const end = new Date(year, month, 0, 23, 59, 59);
  const query = { teacher: teacherId, date: { $gte: start, $lte: end } };
  if (!isSuperAdmin) query.organisation = organisationId;
  return await Session.find(query).populate('subject course semester section').sort('date');
};

export default { markBulk, getStudentSummary, syncOffline, getSessionsByMonth, listSessions };
