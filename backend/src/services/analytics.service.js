const AttendanceSummary = require('../models/AttendanceSummary.model');

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
