// =============================================================
// markAttendance.command.js  ->  ALGORITHM ONLY (source: backend/src/cqrs/commands/markAttendance.command.js)
// =============================================================

// handle(command { sessionId, attendanceArray, teacherId, organisationId, isSuperAdmin }) :
//   thin command wrapper -> delegates to attendanceService.markBulk
