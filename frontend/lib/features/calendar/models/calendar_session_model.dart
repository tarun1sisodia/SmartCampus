import 'package:equatable/equatable.dart';

class CalendarSessionModel extends Equatable {
  const CalendarSessionModel({
    required this.id,
    required this.subjectName,
    required this.section,
    required this.startTime,
    this.endTime,
  });

  final String id;
  final String subjectName;
  final String section;
  final DateTime startTime;
  final DateTime? endTime;

  factory CalendarSessionModel.fromJson(Map<String, dynamic> json) {
    // Backend stores date as `YYYY-MM-DD...` and startTime as `"HH:mm"`.
    final base = DateTime.tryParse((json['date'] ?? '').toString());

    DateTime combine(DateTime date, String? time) {
      if (time == null || !time.contains(':')) return date;
      final parts = time.split(':');
      try {
        return DateTime(date.year, date.month, date.day, int.parse(parts[0]), int.parse(parts[1]));
      } catch (_) {
        return date;
      }
    }

    final sectionValue = json['section'] is Map
        ? (json['section']['name'] ?? '')
        : (json['section'] ?? json['classSection'] ?? 'A');

    return CalendarSessionModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      subjectName: (json['subjectName'] ?? json['subject']?['name'] ?? 'Unknown Subject').toString(),
      section: sectionValue.toString(),
      startTime: combine(base ?? DateTime.now(), json['startTime']?.toString()),
      endTime: json['endTime'] == null
          ? null
          : combine(base ?? DateTime.now(), json['endTime'].toString()),
    );
  }

  @override
  List<Object?> get props => [id, subjectName, section, startTime, endTime];
}
