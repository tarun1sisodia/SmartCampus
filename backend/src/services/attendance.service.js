import Session from '../models/Session.model.js';
import AttendanceSummary from '../models/AttendanceSummary.model.js';
import Attendance from '../models/Attendance.model.js';
import Student from '../models/Student.model.js';
import eventBus from './eventBus.service.js';

export const markBulk = async (sessionId, attendanceArray, teacherId, organisationId, isSuperAdmin) => {
  const session = await Session.findById(sessionId);
  if (!session) throw Object.assign(new Error('Session not found'), { status: 404 });

  if (!isSuperAdmin && String(session.organisation) !== String(organisationId)) {
    throw Object.assign(new Error('Forbidden: Session belongs to another organisation'), { status: 403 });
  }

  // Only the session's owning teacher (or a super admin) may mark attendance.
  if (!isSuperAdmin && String(session.teacher) !== String(teacherId)) {
    throw Object.assign(new Error('Forbidden: Only the session teacher can mark attendance'), { status: 403 });
  }

  const validStatuses = ['present', 'absent', 'late', 'excused'];
  let updatedCount = 0;

  for (const item of attendanceArray || []) {
    if (!item?.studentId || !validStatuses.includes(item.status)) continue;

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
      teacherId,
      newStatus: item.status,
      oldStatus
    });

    updatedCount++;
  }

  return { updatedCount };
};

export const getStudentSummary = async (studentId, organisationId, isSuperAdmin, semesterId) => {
  const query = { student: studentId };
  if (!isSuperAdmin) query.organisation = organisationId;
  if (semesterId) query.semester = semesterId;

  const result = await AttendanceSummary.aggregate([
    { $match: query },
    { $group: { _id: '$status', count: { $sum: 1 } } }
  ]);

  let total = 0;
  let present = 0;
  result.forEach(r => {
    total += r.count;
    if (r._id === 'present' || r._id === 'late') present += r.count; // 'late' counts towards attendance %
  });

  return { result, total, percentage: total > 0 ? (present / total) * 100 : 0 };
};

export const syncOffline = async (teacherId, offlineRecords, organisationId) => {
  const results = [];
  const validStatuses = ['present', 'absent', 'late', 'excused'];

  for (const record of offlineRecords || []) {
    try {
      // Session must exist AND belong to this teacher (tenant + owner check).
      const session = await Session.findOne({ _id: record.sessionId, teacher: teacherId });
      if (!session) {
        results.push({ studentId: record?.studentId, error: 'Session not found' });
        continue;
      }

      if (!record?.studentId || !validStatuses.includes(record.status)) {
        results.push({ studentId: record?.studentId, error: 'Invalid record' });
        continue;
      }

      // Conflict resolution: last write wins by timestamp.
      const clientTimestamp = new Date(record.timestamp);
      if (Number.isNaN(clientTimestamp.getTime())) {
        results.push({ studentId: record.studentId, error: 'Invalid timestamp' });
        continue;
      }

      const existing = await Attendance.findOne({ session: record.sessionId, student: record.studentId });
      if (existing && existing.timestamp > clientTimestamp) {
        results.push({ studentId: record.studentId, status: 'skipped', reason: 'Server has newer data' });
        continue;
      }

      await Attendance.findOneAndUpdate(
        { session: record.sessionId, student: record.studentId },
        {
          $set: {
            status: record.status,
            markedBy: teacherId,
            timestamp: clientTimestamp,
            remarks: record.remarks,
            organisation: session.organisation
          }
        },
        { upsert: true }
      );
      results.push({ studentId: record.studentId, status: record.status, synced: true });
    } catch (err) {
      results.push({ studentId: record?.studentId, error: err.message });
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
    const s = startDate ? new Date(startDate) : null;
    const e = endDate ? new Date(endDate) : null;
    if (s && !isNaN(s.getTime())) query.date.$gte = s;
    if (e && !isNaN(e.getTime())) query.date.$lte = e;
    if (Object.keys(query.date).length === 0) delete query.date;
  }

  if (subjectId) query.subject = subjectId;
  if (courseId) query.course = courseId;

  return await Session.find(query)
    .populate('subject course semester section teacher', 'name code title')
    .sort({ date: 1, startTime: 1 })
    .limit(500); // bound unfiltered queries
};

export const getSessionsByMonth = async (teacherId, yearMonth, organisationId, isSuperAdmin) => {
  if (!yearMonth || !/^\d{4}-\d{2}$/.test(String(yearMonth))) {
    throw Object.assign(new Error('month must be in YYYY-MM format'), { status: 400 });
  }
  const [year, month] = String(yearMonth).split('-').map(Number);
  if (month < 1 || month > 12) {
    throw Object.assign(new Error('Invalid month'), { status: 400 });
  }
  const start = new Date(year, month - 1, 1);
  const end = new Date(year, month, 0, 23, 59, 59, 999);
  const query = { teacher: teacherId, date: { $gte: start, $lte: end } };
  if (!isSuperAdmin) query.organisation = organisationId;
  return await Session.find(query).populate('subject course semester section').sort('date');
};

export default { markBulk, getStudentSummary, syncOffline, getSessionsByMonth, listSessions };
