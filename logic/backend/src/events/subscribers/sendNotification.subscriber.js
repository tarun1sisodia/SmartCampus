// =============================================================
// sendNotification.subscriber.js  ->  ALGORITHM ONLY (source: backend/src/events/subscribers/sendNotification.subscriber.js)
// =============================================================

// setup() : on 'attendance.marked' { teacherId, studentId, oldStatus, newStatus } :
//   teacherId present -> emitToUser(teacherId, 'attendance-updated', data)   // live dashboard update
//   status changed absent -> present -> sendPushNotification(student, 'Attendance Marked', 'marked present')
