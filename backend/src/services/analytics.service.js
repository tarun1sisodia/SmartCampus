const AttendanceSummary = require('../models/AttendanceSummary.model');
const Session = require('../models/Session.model');
const Attendance = require('../models/Attendance.model');
const Student = require('../models/Student.model');
exports.getClassAttendance = async (courseId, semesterId, sectionId, organisationId, isSuperAdmin) => {
  const query = {};
  if (!isSuperAdmin) query.organisation = organisationId;
  if (courseId) query.course = courseId;
  if (semesterId) query.semester = semesterId;
  if (sectionId) query.section = sectionId;

  const result = await AttendanceSummary.aggregate([
    { $match: query },
    { 
      $group: { 
        _id: "$student", 
        studentName: { $first: "$studentName" },
        rollNumber: { $first: "$rollNumber" },
        presentCount: { 
          $sum: { $cond: [{ $in: ["$status", ["present", "late"]] }, 1, 0] } 
        }, 
        totalSessions: { $sum: 1 } 
      } 
    }
  ]);

  let globalPresentCount = 0;
  let globalTotalSessions = 0;

  const studentList = result.map(r => {
    globalPresentCount += r.presentCount;
    globalTotalSessions += r.totalSessions;
    return {
      ...r,
      percentage: r.totalSessions > 0 ? (r.presentCount / r.totalSessions) * 100 : 0
    };
  });

  const overall = globalTotalSessions > 0 ? (globalPresentCount / globalTotalSessions) * 100 : 0;

  return { overall, studentList };
};

exports.getTeacherPerformance = async (teacherId, startDate, endDate, organisationId, isSuperAdmin) => {
  const match = { teacher: teacherId };
  if (!isSuperAdmin) match.organisation = organisationId;
  if (startDate) match.date = { $gte: new Date(startDate) };
  if (endDate) match.date = { ...match.date, $lte: new Date(endDate) };
  
  const sessions = await Session.find(match).populate('subject');
  const totalSessions = sessions.length;
  const subjectWise = {};
  
  for (const session of sessions) {
    const subjectId = session.subject._id.toString();
    const attendanceCount = await Attendance.countDocuments({ session: session._id, status: { $in: ['present','late'] } });
    const totalStudents = await Student.countDocuments({ organisation: session.organisation, course: session.course, semester: session.semester, section: session.section });
    const percentage = totalStudents ? (attendanceCount / totalStudents) * 100 : 0;
    
    if (!subjectWise[subjectId]) subjectWise[subjectId] = { subjectName: session.subject.name, total: 0, sumPercentage: 0 };
    subjectWise[subjectId].total++;
    subjectWise[subjectId].sumPercentage += percentage;
  }
  
  const subjectSummary = Object.values(subjectWise).map(s => ({ subject: s.subjectName, avgAttendance: s.sumPercentage / s.total }));
  const overallAttendance = subjectSummary.reduce((acc, s) => acc + s.avgAttendance, 0) / (subjectSummary.length || 1);
  return { overallAttendance, subjectWise: subjectSummary, totalSessions };
};
