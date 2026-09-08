import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../models/calendar_session_model.dart';

class CalendarRepository {
  CalendarRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<CalendarSessionModel>> fetchSessionsForMonth(int year, int month) async {
    final monthString = '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
    final response = await _apiClient.dio.get(
      Endpoints.sessionsByMonth,
      queryParameters: {'month': monthString},
    );

    if (response.statusCode != 200) {
      return <CalendarSessionModel>[];
    }

    final payload = response.data;
    final rawList = (payload is Map<String, dynamic>)
        ? (payload['data'] ?? payload['sessions'] ?? <dynamic>[])
        : (payload as List<dynamic>);

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(CalendarSessionModel.fromJson)
        .toList();
  }
}
