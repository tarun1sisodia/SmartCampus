import AttendanceSummary from '../../models/AttendanceSummary.model.js';
import Attendance from '../../models/Attendance.model.js';
import Session from '../../models/Session.model.js';
import Student from '../../models/Student.model.js';

export const refreshAttendanceSummary = async (eventData) => {
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

export default { refreshAttendanceSummary };
