// =============================================================
// analytics.service.js  ->  ALGORITHM ONLY (source: backend/src/services/analytics.service.js)
// =============================================================

// getClassAttendance(courseId?, semesterId?, sectionId?, orgId, isSuperAdmin) :
//   aggregate AttendanceSummary by student:
//     presentCount = count of status in [present, late]; totalSessions = all rows
//     percentage per student ; overall = global sum / global total * 100

// getTeacherPerformance(teacherId, startDate?, endDate?, orgId, isSuperAdmin) :
//   load the teacher's sessions in range (+subject)
//   per session: present-ish attendance count / students enrolled in that class -> %
//   average % per subject ; overall = mean of subject averages; return with totalSessions
