// =============================================================
// attendance.controller.js  ->  ALGORITHM ONLY (source: backend/src/controllers/attendance.controller.js)
// =============================================================

// SESSION_FIELDS whitelist: subject, course, semester, section, date, startTime, endTime, topic, isHoliday

// createSession : copy ONLY whitelisted fields (mass-assignment guard); teacher = req.user.id;
//   organisation = own org (super admin may pass organisationId); create -> 201

// listSessions : ?month=YYYY-MM -> calendar by month; else filters { date('today'|date), subjectId, courseId, startDate, endDate }

// getSession : org-scoped findOne + populate names; 404; attach attendance[] with student info -> detail payload

// markBulk : { sessionId, attendance[] } -> service.markBulk (owner+tenant checked there) -> { updatedCount }

// getBySession : all attendance rows of a session (org-scoped) + student name/roll
// studentSummary : per-student totals + percentage (optional ?semesterId)
// syncOffline : { records } -> service.syncOffline -> per-record sync result array
// listSessionsByMonth : validate 'YYYY-MM' -> monthly sessions
