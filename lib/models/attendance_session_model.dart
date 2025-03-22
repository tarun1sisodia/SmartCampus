class AttendanceSessionModel {
  final String id;
  final String classId;
  final DateTime date;
  final String? startTime;
  final String? endTime;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AttendanceSessionModel({
    required this.id,
    required this.classId,
    required this.date,
    this.startTime,
    this.endTime,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory AttendanceSessionModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSessionModel(
      id: json['id'],
      classId: json['class_id'],
      date: DateTime.parse(json['date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      createdBy: json['created_by'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'date': date.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
