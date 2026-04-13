class SubjectModel {
  final String id;
  final String name;
  // final String courseId;
  final String? code;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SubjectModel({
    required this.id,
    required this.name,
    // required this.courseId,
    this.code,
    this.createdAt,
    this.updatedAt,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'],
      name: json['name'],
      // courseId: json['course_id'],
      code: json['code'],
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
      'name': name,
      // 'course_id': courseId,
      'code': code,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
