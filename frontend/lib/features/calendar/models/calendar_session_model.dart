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
    return CalendarSessionModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      subjectName: (json['subjectName'] ?? json['subject']?['name'] ?? 'Unknown Subject').toString(),
      section: (json['section'] ?? json['classSection'] ?? 'A').toString(),
      startTime: DateTime.tryParse((json['startTime'] ?? '').toString()) ?? DateTime.now(),
      endTime: json['endTime'] == null ? null : DateTime.tryParse(json['endTime'].toString()),
    );
  }

  @override
  List<Object?> get props => [id, subjectName, section, startTime, endTime];
}
