import 'package:equatable/equatable.dart';

class SessionModel extends Equatable {
  final String id;
  final String subjectName;
  final String courseId;
  final DateTime startTime;
  final DateTime? endTime;
  final int totalStudents;
  final int? presentCount;
  final String status; // 'scheduled', 'ongoing', 'completed'

  const SessionModel({
    required this.id,
    required this.subjectName,
    required this.courseId,
    required this.startTime,
    this.endTime,
    required this.totalStudents,
    this.presentCount,
    required this.status,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] ?? json['sessionId'] ?? '',
      subjectName: json['subjectName'] ?? json['subject']?['name'] ?? 'Unknown Subject',
      courseId: json['courseId'] ?? json['course']?['id'] ?? '',
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      totalStudents: json['totalStudents'] ?? 0,
      presentCount: json['presentCount'],
      status: json['status'] ?? 'scheduled',
    );
  }

  @override
  List<Object?> get props => [id, subjectName, courseId, startTime, endTime, totalStudents, presentCount, status];
}
