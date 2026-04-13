import {  analyticsQueue  } from '../config/bull.js';
import AttendanceSummary from '../models/AttendanceSummary.model.js';
import {  sendPushNotification  } from '../services/notification.service.js';

export const setupSendReminders = () => {
  analyticsQueue.process('send-reminders', async (job) => {
    // 1. Aggregate attendance per student across the whole system (or orgs)
    const lowAttendanceStudents = await AttendanceSummary.aggregate([
      {
        $group: {
          _id: "$student",
          total: { $sum: 1 },
          present: { $sum: { $cond: [{ $in: ["$status", ["present", "late"]] }, 1, 0] } }
        }
      },
      {
        $project: {
          student: "$_id",
          percentage: { $multiply: [{ $divide: ["$present", "$total"] }, 100] }
        }
      },
      { $match: { percentage: { $lt: 75 } } }
    ]);

    for (const record of lowAttendanceStudents) {
      // 2. Identify and notify parents/users associated with the student
      // In a real system, we'd fetch the parent/student user ID here.
      // For now, we assume studentId maps to a User record for notifications.
      await sendPushNotification(
        record.student, 
        "Attendance Warning", 
        `Your semester attendance is currently ${record.percentage.toFixed(1)}%. Please attend upcoming sessions.`
      );
    }
  });

  // Run weekly at 8 AM on Mondays
  analyticsQueue.add('send-reminders', {}, { repeat: { cron: '0 8 * * 1' } });
};

export default { setupSendReminders };
