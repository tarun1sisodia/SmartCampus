class ClassModel {
  final String id;
  final String teacherId;
  final String subjectId;
  final String courseId;
  final int year;
  final String? section;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Denormalized fields for UI display
  final String? subjectName;
  final String? courseName;

  ClassModel({
    required this.id,
    required this.teacherId,
    required this.subjectId,
    required this.courseId,
    required this.year,
    this.section,
    this.createdAt,
    this.updatedAt,
    this.subjectName,
    this.courseName,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'],
      teacherId: json['teacher_id'],
      subjectId: json['subject_id'],
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
      subjectName: json['subject_name'],
      courseName: json['course_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacher_id': teacherId,
      'subject_id': subjectId,
      'course_id': courseId,
      'year': year,
      'section': section,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
