class ClassModel {
  final String id;
  final String teacherId;
  final String subjectId;
  final String courseId;
  final int semester;
  final String? section;
  final String? subjectName;
  final String? courseName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClassModel({
    required this.id,
    required this.teacherId,
    required this.subjectId,
    required this.courseId,
    required this.semester,
    this.section,
    this.subjectName,
    this.courseName,
    this.createdAt,
    this.updatedAt,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'],
      teacherId: json['teacher_id'],
      subjectId: json['subject_id'],
      courseId: json['course_id'],
      semester: json['semester'],
      section: json['section'],
      subjectName: json['subject_name'],
      courseName: json['course_name'],
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
      'teacher_id': teacherId,
      'subject_id': subjectId,
      'course_id': courseId,
      'semester': semester,
      'section': section,
      'subject_name': subjectName,
      'course_name': courseName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
