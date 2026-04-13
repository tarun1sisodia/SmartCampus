import '../../../core/api/api_client.dart';
import '../models/attendance_record_model.dart';

class AttendanceRepository {
  final ApiClient _apiClient;

  AttendanceRepository(this._apiClient);

  Future<List<AttendanceRecordModel>> fetchStudentsForSession(String sessionId) async {
    try {
      final response = await _apiClient.dio.get('/attendance/session/$sessionId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data']['records'];
        return data.map((json) => AttendanceRecordModel.fromJson(json)).toList();
      }
    } catch (e) {
      rethrow;
    }
    return [];
  }

  Future<void> markAttendance({
    required String sessionId,
    required String studentId,
    required String status,
    String? remarks,
  }) async {
    await _apiClient.dio.post('/attendance/mark', data: {
      'sessionId': sessionId,
      'studentId': studentId,
      'status': status,
      'remarks': remarks,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> markBulkAttendance({
    required String sessionId,
    required List<Map<String, dynamic>> records,
  }) async {
    await _apiClient.dio.post('/attendance/mark', data: {
      'sessionId': sessionId,
      'records': records,
    });
  }
}
