class Endpoints {
  Endpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/users/change-password';

  // Sessions & Attendance
  static const String sessions = '/sessions';
  static const String sessionsByMonth = '/attendance/sessions/month';
  static const String markAttendance = '/attendance/mark';
  static const String syncAttendance = '/attendance/sync';
  static const String attendanceBySession = '/attendance/session';
  static const String attendanceByStudent = '/attendance/student';
  static const String generateQr = '/attendance/qr/generate';
  static const String verifyQr = '/attendance/qr/verify';

  // Students
  static const String students = '/students';

  // Analytics
  static const String teacherAnalytics = '/analytics/teacher';

  // Notifications
  static const String registerNotificationToken = '/notifications/register-token';

  // Profile
  static const String me = '/users/me';
  static const String uploadProfilePhoto = '/users/me/photo';
}

/// Backward-compatible alias while old modules are migrated.
class ApiEndpoints {
  static const String login = Endpoints.login;
  static const String refresh = Endpoints.refresh;
  static const String logout = Endpoints.logout;
  static const String forgotPassword = Endpoints.forgotPassword;
  static const String resetPassword = Endpoints.resetPassword;
  static const String changePassword = Endpoints.changePassword;
  static const String sessions = Endpoints.sessions;
  static const String markAttendance = Endpoints.markAttendance;
  static const String syncAttendance = Endpoints.syncAttendance;
  static const String sessionDetail = Endpoints.attendanceBySession;
  static const String teacherStats = Endpoints.teacherAnalytics;
}
