import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../models/student_detail_model.dart';

class StudentRepository {
  StudentRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<StudentDetailModel> fetchStudentDetails(String studentId) async {
    final response = await _apiClient.dio.get('${Endpoints.students}/$studentId');
    final data = response.data['data'] ?? response.data['student'] ?? response.data;
    return StudentDetailModel.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<StudentAttendanceSummary> fetchStudentAttendanceSummary(
    String studentId,
  ) async {
    final response = await _apiClient.dio.get(
      '${Endpoints.attendanceByStudent}/$studentId',
    );
    final data = response.data['data'] ?? response.data['summary'] ?? response.data;
    return StudentAttendanceSummary.fromJson((data as Map).cast<String, dynamic>());
  }
}
