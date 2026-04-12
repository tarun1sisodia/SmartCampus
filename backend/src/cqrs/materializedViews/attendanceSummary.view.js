const AttendanceSummary = require('../../models/AttendanceSummary.model');
const Attendance = require('../../models/Attendance.model');
const Session = require('../../models/Session.model');
const Student = require('../../models/Student.model');

exports.refreshAttendanceSummary = async (eventData) => {
  const { sessionId, studentId, newStatus } = eventData;

  const session = await Session.findById(sessionId);
  const student = await Student.findById(studentId);

  if (!session || !student) return;

  await AttendanceSummary.findOneAndUpdate(
    { session: sessionId, student: studentId },
    {
      student: studentId,
      session: sessionId,
      course: session.course,
      subject: session.subject,
      semester: session.semester,
      organisation: session.organisation,
      date: session.date,
      status: newStatus,
      studentName: student.name,
      rollNumber: student.rollNumber
    },
    { upsert: true, new: true }
  );
};
