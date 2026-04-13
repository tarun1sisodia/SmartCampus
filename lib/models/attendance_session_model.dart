class AttendanceSessionModel {
  final String id;
  final String classId;
  final DateTime date;
  final String? startTime;
  final String? endTime;
  final String? createdBy;
  final String? subjectName;
  final String? courseName;
  final int? semester;
  final String? section;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String status;
  final DateTime? closedAt;

  AttendanceSessionModel({
    required this.id,
    required this.classId,
    required this.date,
    this.startTime,
    this.endTime,
    this.createdBy,
    this.subjectName,
    this.courseName,
    this.semester,
    this.section,
    this.createdAt,
    this.updatedAt,
    this.status = 'open',
    this.closedAt,
  });

  factory AttendanceSessionModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSessionModel(
        id: json['id'],
        classId: json['class_id'],
        date: DateTime.parse(json['date']),
        startTime: json['start_time'],
        endTime: json['end_time'],
        createdBy: json['created_by'],
        subjectName: json['subject_name'],
        courseName: json['course_name'],
        semester: json['semester'],
        section: json['section'],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
        status: json['status'] ?? 'open',
        closedAt: json['closed_at'] != null
            ? DateTime.parse(json['closed_at'])
            : null);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'date': date.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'created_by': createdBy,
      'subject_name': subjectName,
      'course_name': courseName,
      'semester': semester,
      'section': section,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'status': status,
      'closed_at': closedAt?.toIso8601String(),
    };
  }
}
