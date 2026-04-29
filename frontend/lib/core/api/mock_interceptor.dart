import 'dart:convert';
import 'package:dio/dio.dart';
import 'mock_data.dart';

class MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final path = options.path;
    final method = options.method.toUpperCase();

    dynamic responseData;
    int statusCode = 200;

    try {
      if (path.contains('/auth/login') && method == 'POST') {
        responseData = MockData.loginResponse;
      } else if (path.contains('/auth/me') && method == 'GET') {
        responseData = MockData.meResponse;
      } else if (path.contains('/sessions/teacher') && method == 'GET') {
        responseData = MockData.todaySessions;
      } else if (path.contains('/sessions/') && method == 'GET') {
        final parts = path.split('/');
        final sessionId = parts.last;
        responseData = MockData.getSessionDetails(sessionId);
      } else if (path.contains('/attendance/session/') && method == 'GET') {
        responseData = MockData.sessionAttendance;
      } else if (path.contains('/analytics/teacher') && method == 'GET') {
        responseData = MockData.teacherAnalytics;
      } else if (path.contains('/students/') && method == 'GET') {
        final parts = path.split('/');
        final studentId = parts.last;
        responseData = MockData.getStudentDetails(studentId);
      } else if (path.contains('/attendance/mark') || path.contains('/attendance/bulk-mark') || path.contains('/profile')) {
        responseData = {"status": "success", "message": "Mock operation successful"};
      } else if (path.contains('/auth/logout')) {
        responseData = {"status": "success", "message": "Logged out successfully"};
      } else {
        // Fallback for unknown endpoints
        responseData = {"status": "success", "message": "Mock generic response", "data": {}};
      }

      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: statusCode,
          data: responseData,
        ),
      );
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: "Mock Error: $e",
          type: DioExceptionType.unknown,
        ),
      );
    }
  }
}
