import 'package:equatable/equatable.dart';

class SessionModel extends Equatable {
  final String id;
  final String subjectName;
  final String section;
  final String courseId;
  final String? topic;
  final bool isHoliday;
  final DateTime startTime;
  final DateTime? endTime;
  final int totalStudents;
  final int? presentCount;
  final String status; // 'scheduled', 'ongoing', 'completed'

  const SessionModel({
    required this.id,
    required this.subjectName,
    required this.section,
    required this.courseId,
    this.topic,
    this.isHoliday = false,
    required this.startTime,
    this.endTime,
    required this.totalStudents,
    this.presentCount,
    required this.status,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    final normalized = _normalizeJson(json);
    
    // Parse the base date
    final dateStr = normalized['date']?.toString();
    final baseDate = dateStr != null ? DateTime.parse(dateStr).toLocal() : DateTime.now();

    // Helper to combine date with "HH:mm" time string
    DateTime combineDateTime(DateTime date, String? timeStr) {
      if (timeStr == null || !timeStr.contains(':')) return date;
      try {
        final parts = timeStr.split(':');
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        return DateTime(date.year, date.month, date.day, hours, minutes);
      } catch (_) {
        return date;
      }
    }

    return SessionModel(
      id: normalized['id'] as String,
      subjectName: normalized['subjectName'] as String,
      section: normalized['section'] as String,
      courseId: normalized['courseId'] as String,
      topic: normalized['topic'] as String?,
      isHoliday: normalized['isHoliday'] as bool? ?? false,
      startTime: combineDateTime(baseDate, normalized['startTime']?.toString()),
      endTime: normalized['endTime'] != null ? combineDateTime(baseDate, normalized['endTime']?.toString()) : null,
      totalStudents: normalized['totalStudents'] as int? ?? 0,
      presentCount: normalized['presentCount'] as int?,
      status: normalized['status'] as String? ?? 'scheduled',
    );
  }

  static Map<String, dynamic> _normalizeJson(Map<String, dynamic> json) {
    return {
      ...json,
      'id': (json['_id'] ?? json['id'] ?? json['sessionId'] ?? '').toString(),
      'subjectName': json['subjectName'] ?? json['subject']?['name'] ?? 'Unknown Subject',
      'section': json['section']?['name']?.toString() ?? json['section']?.toString() ?? 'A',
      'courseId': json['courseId'] ?? json['course']?['id'] ?? json['course']?['_id'] ?? '',
      'isHoliday': json['isHoliday'] ?? json['is_holiday'] ?? false,
    };
  }

  @override
  List<Object?> get props => [
        id,
        subjectName,
        section,
        courseId,
        topic,
        isHoliday,
        startTime,
        endTime,
        totalStudents,
        presentCount,
        status,
      ];
}
