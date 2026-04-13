class ApiEndpoints {
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String updateProfile = '/auth/update-profile';
  
  static const String sessions = '/attendance/sessions';
  static const String sessionDetail = '/attendance/session';
  static const String markAttendance = '/attendance/mark';
  static const String syncAttendance = '/attendance/sync';
  
  static const String teacherStats = '/analytics/teacher';
}
