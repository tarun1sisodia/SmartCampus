// =============================================================
// sendReminders.job.js  ->  ALGORITHM ONLY (source: backend/src/jobs/sendReminders.job.js)
// =============================================================

// setupSendReminders() :
//   analyticsQueue.process('send-reminders') :
//     aggregate AttendanceSummary per student -> percentage = (present+late)/total*100
//     every student under 75% -> push notification 'Attendance Warning' with their percentage
//   schedule cron '0 8 * * 1' (Mondays 08:00)
