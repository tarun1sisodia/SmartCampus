import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../models/attendance_record_model.dart';

class AttendanceRepository {
  final ApiClient _apiClient;

  AttendanceRepository(this._apiClient);

  Future<List<AttendanceRecordModel>> fetchStudentsForSession(String sessionId) async {
    try {
      final response = await _apiClient.dio.get(
        Endpoints.students,
        queryParameters: {'sessionId': sessionId},
      );
      if (response.statusCode == 200) {
        final payload = response.data;
        final List<dynamic> data = (payload['data'] ?? payload['students'] ?? payload) as List<dynamic>;
        return data.map((json) => AttendanceRecordModel.fromJson(json)).toList();
      }
    } catch (e) {
      rethrow;
    }
    return [];
  }

  Future<void> markAttendance({
    required String sessionId,
    required List<AttendanceRecordModel> records,
  }) async {
    await _apiClient.dio.post(Endpoints.markAttendance, data: {
      'sessionId': sessionId,
      'attendance': records
          .where((r) => r.status != 'pending')
          .map((r) => {
                'studentId': r.studentId,
                'status': r.status,
                'timestamp': DateTime.now().toUtc().toIso8601String(),
              })
          .toList(),
    });
  }

  Future<void> syncOffline(List<Map<String, dynamic>> records) async {
    await _apiClient.dio.post(
      Endpoints.syncAttendance,
      data: {'records': records},
    );
  }
}
