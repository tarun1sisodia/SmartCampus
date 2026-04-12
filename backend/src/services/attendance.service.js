const Session = require('../models/Session.model');
const Attendance = require('../models/Attendance.model');
const Student = require('../models/Student.model');
const eventBus = require('./eventBus.service');

exports.markBulk = async (sessionId, attendanceArray, teacherId, organisationId, isSuperAdmin) => {
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

exports.getStudentSummary = async (studentId, organisationId, isSuperAdmin, semesterId) => {
  // Simple fallback logic since actual caching or full aggregation is specific for CQRS
  const AttendanceSummary = require('../models/AttendanceSummary.model');
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
