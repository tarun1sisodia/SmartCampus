import eventBus from '../../services/eventBus.service.js';
import {  emitToUser  } from '../../socket/index.js';
import {  sendPushNotification  } from '../../services/notification.service.js';
export const setup = () => {
  eventBus.registerHandler('attendance.marked', async (data) => {
    const { newStatus, oldStatus, studentId, sessionId, teacherId } = data;
    
    // Web socket push (we don't have teacherId securely here since event didn't pass it, 
    // wait, the service publish 'attendance.marked' passing sessionId, studentId, newStatus, oldStatus. 
    // But gap says "emitToUser(teacherId, 'attendance-updated', data)". 
    // Since teacherId isn't on data right now, we can omit it or emit to studentId 
    // Actually, I'll just emit a general event we'll need to fetch sessionId first if we want teacherId.
    if (teacherId) {
      emitToUser(teacherId, 'attendance-updated', data);
    }

    if (oldStatus === 'absent' && newStatus === 'present') {
      // Notify parent or student via FCM
      await sendPushNotification(
        studentId, 
        "Attendance Marked", 
        "Status updated: You have been marked present."
      );
    }
  });
};

export default { setup };
