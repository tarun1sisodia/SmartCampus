import 'package:equatable/equatable.dart';

class SessionModel extends Equatable {
  final String id;
  final String subjectName;
  final String section;
  final String courseId;
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
    required this.startTime,
    this.endTime,
    required this.totalStudents,
    this.presentCount,
    required this.status,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    // Parse the base date
    final dateStr = json['date']?.toString();
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
      id: json['_id'] ?? json['id'] ?? json['sessionId'] ?? '',
      subjectName: json['subjectName'] ?? json['subject']?['name'] ?? 'Unknown Subject',
      section: json['section']?['name']?.toString() ?? json['section']?.toString() ?? 'A',
      courseId: json['courseId'] ?? json['course']?['id'] ?? json['course']?['_id'] ?? '',
      startTime: combineDateTime(baseDate, json['startTime']?.toString()),
      endTime: json['endTime'] != null ? combineDateTime(baseDate, json['endTime']?.toString()) : null,
      totalStudents: json['totalStudents'] ?? 0,
      presentCount: json['presentCount'],
      status: json['status'] ?? 'scheduled',
    );
  }

  @override
  List<Object?> get props => [id, subjectName, section, courseId, startTime, endTime, totalStudents, presentCount, status];
}
