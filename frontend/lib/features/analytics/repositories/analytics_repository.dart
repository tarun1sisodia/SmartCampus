import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../../core/cache/hive_service.dart';
import '../models/teacher_stats_model.dart';
import 'dart:convert';

class AnalyticsRepository {
  final ApiClient _apiClient;
  final HiveService _hiveService;

  AnalyticsRepository(this._apiClient, this._hiveService);

  Future<TeacherStatsModel> fetchTeacherStats({
    required String teacherId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '${Endpoints.teacherAnalytics}/$teacherId',
        queryParameters: {
          'startDate': startDate.toIso8601String().split('T').first,
          'endDate': endDate.toIso8601String().split('T').first,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final stats = TeacherStatsModel.fromJson(data);
        
        // Cache for 1 hour (timestamp + data)
        await _hiveService.cacheBox.put(
          'teacher_stats_$teacherId',
          jsonEncode({
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'data': data,
          }),
        );
        
        return stats;
      }
    } catch (e) {
      rethrow;
    }
    throw Exception('Failed to fetch statistics');
  }

  TeacherStatsModel? getCachedStats(String teacherId) {
    final cached = _hiveService.cacheBox.get('teacher_stats_$teacherId');
    if (cached != null) {
      final decoded = jsonDecode(cached);
      final timestamp = decoded['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // If less than 1 hour old
      if (now - timestamp < 3600000) {
        return TeacherStatsModel.fromJson(decoded['data']);
      }
    }
    return null;
  }
}
