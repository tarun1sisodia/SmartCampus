import 'package:smart_campus/core/api/api_client.dart';
import 'package:smart_campus/core/api/endpoints.dart';
import 'package:smart_campus/features/home/models/session_model.dart';
import 'package:smart_campus/features/session/models/session_detail_model.dart';

class SessionRepository {
  final ApiClient _apiClient;

  SessionRepository(this._apiClient);

  Future<List<SessionModel>> fetchSessionHistory() async {
    try {
      final now = DateTime.now().toUtc();
      final startDate = now.subtract(const Duration(days: 30));
      final response = await _apiClient.dio.get(
        ApiEndpoints.sessions,
        queryParameters: {
          'startDate': startDate.toIso8601String().split('T').first,
          'endDate': now.toIso8601String().split('T').first,
        },
      );
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? response.data['sessions'] ?? response.data ?? [];
        return data.map((json) => SessionModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<SessionDetailModel> fetchSessionDetails(String sessionId) async {
    try {
      final response = await _apiClient.dio.get('${ApiEndpoints.sessions}/$sessionId');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data['session'] ?? response.data;
        return SessionDetailModel.fromJson(data);
      }
      throw Exception('Failed to load session details');
    } catch (e) {
      rethrow;
    }
  }
}
