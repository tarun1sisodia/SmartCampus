import AttendanceSummary from '../../models/AttendanceSummary.model.js';

export const handle = async (query) => {
  const { courseId, semesterId, sectionId, organisationId, isSuperAdmin } = query;
  
  const filter = {};
  if (!isSuperAdmin) filter.organisation = organisationId;
  if (courseId) filter.course = courseId;
  if (semesterId) filter.semester = semesterId;
  if (sectionId) filter.section = sectionId;

  const result = await AttendanceSummary.aggregate([
    { $match: filter },
    { 
      $group: { 
        _id: "$student", 
        studentName: { $first: "$studentName" },
        rollNumber: { $first: "$rollNumber" },
        presentCount: { 
          $sum: { $cond: [{ $eq: ["$status", "present"] }, 1, 0] } 
        }, 
        total: { $sum: 1 } 
      } 
    }
  ]);
  
  return result;
};

export default { handle };
