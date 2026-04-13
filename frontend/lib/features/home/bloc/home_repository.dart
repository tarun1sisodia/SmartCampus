import 'dart:convert';
import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../../core/cache/hive_service.dart';
import '../models/session_model.dart';

class HomeRepository {
  final ApiClient _apiClient;
  final HiveService _hiveService;

  HomeRepository(this._apiClient, this._hiveService);

  static const String _todaySessionsCacheKey = 'today_sessions';
  static const String _todaySessionsExpiryKey = 'today_sessions_expiry';

  Future<List<SessionModel>> fetchTodaySessions() async {
    try {
      final response = await _apiClient.dio.get(
        Endpoints.sessions,
        queryParameters: {'date': 'today'},
      );

      if (response.statusCode == 200) {
        final payload = response.data;
        final List<dynamic> data = (payload is Map<String, dynamic>)
            ? (payload['data'] ?? payload['sessions'] ?? <dynamic>[])
            : (payload as List<dynamic>);
        final sessions = data.map((json) => SessionModel.fromJson(json)).toList();

        await _hiveService.sessionCacheBox.put(_todaySessionsCacheKey, jsonEncode(data));
        await _hiveService.sessionCacheBox.put(
          _todaySessionsExpiryKey,
          _midnightUtc().toIso8601String(),
        );

        return sessions;
      }
    } catch (e) {
      rethrow;
    }
    return [];
  }

  List<SessionModel>? getCachedTodaySessions() {
    final expiryRaw = _hiveService.sessionCacheBox.get(_todaySessionsExpiryKey);
    if (expiryRaw is! String) return null;

    final expiresAt = DateTime.tryParse(expiryRaw);
    if (expiresAt == null || DateTime.now().toUtc().isAfter(expiresAt)) {
      _hiveService.sessionCacheBox.delete(_todaySessionsCacheKey);
      _hiveService.sessionCacheBox.delete(_todaySessionsExpiryKey);
      return null;
    }

    final cachedData = _hiveService.sessionCacheBox.get(_todaySessionsCacheKey);
    if (cachedData is String && cachedData.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(cachedData);
      return decoded.map((json) => SessionModel.fromJson(json)).toList();
    }
    return null;
  }

  DateTime _midnightUtc() {
    final now = DateTime.now().toUtc();
    return DateTime.utc(now.year, now.month, now.day + 1);
  }
}
