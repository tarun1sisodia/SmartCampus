class StudentModel {
  final String id;
  final String rollNumber;
  final String name;
  final String courseId;
  final int year;
  final String? section;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Transient field for attendance tracking
  String? attendanceStatus;

  StudentModel({
    required this.id,
    required this.rollNumber,
    required this.name,
    required this.courseId,
    required this.year,
    this.section,
    this.createdAt,
    this.updatedAt,
    this.attendanceStatus,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'],
      rollNumber: json['roll_number'],
      name: json['name'],
      courseId: json['course_id'],
      year: json['year'],
      section: json['section'],
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
      'roll_number': rollNumber,
      'name': name,
      'course_id': courseId,
      'year': year,
      'section': section,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
