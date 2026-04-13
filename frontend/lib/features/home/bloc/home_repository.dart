import 'dart:convert';
import '../../../core/api/api_client.dart';
import '../../../core/cache/hive_service.dart';
import '../models/session_model.dart';

class HomeRepository {
  final ApiClient _apiClient;
  final HiveService _hiveService;

  HomeRepository(this._apiClient, this._hiveService);

  Future<List<SessionModel>> fetchTodaySessions(String teacherId) async {
    try {
      final response = await _apiClient.dio.get('/attendance/sessions', queryParameters: {
        'teacherId': teacherId,
        'date': DateTime.now().toIso8601String().split('T')[0],
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final sessions = data.map((json) => SessionModel.fromJson(json)).toList();
        
        // Cache in Hive
        await _hiveService.cacheBox.put(
          'today_sessions_$teacherId',
          jsonEncode(data),
        );
        
        return sessions;
      }
    } catch (e) {
      rethrow;
    }
    return [];
  }

  List<SessionModel>? getCachedSessions(String teacherId) {
    final cachedData = _hiveService.cacheBox.get('today_sessions_$teacherId');
    if (cachedData != null) {
      final List<dynamic> decoded = jsonDecode(cachedData);
      return decoded.map((json) => SessionModel.fromJson(json)).toList();
    }
    return null;
  }
}
