import 'package:equatable/equatable.dart';

class SubjectModel extends Equatable {
  final String id;
  final String name;
  final String code;
  final int? credits;
  final String? courseId;
  final int? semester;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.code,
    this.credits,
    this.courseId,
    this.semester,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    final normalized = _normalizeJson(json);
    return SubjectModel(
      id: normalized['id'] as String,
      name: normalized['name'] as String,
      code: normalized['code'] as String,
      credits: normalized['credits'] as int?,
      courseId: normalized['courseId'] as String?,
      semester: normalized['semester'] as int?,
    );
  }

  static Map<String, dynamic> _normalizeJson(Map<String, dynamic> json) {
    return {
      ...json,
      'id': (json['id'] ?? json['_id'] ?? '').toString(),
      'courseId': json['courseId'] ?? json['course_id'],
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'credits': credits,
      'courseId': courseId,
      'semester': semester,
    };
  }

  @override
  List<Object?> get props => [id, name, code, credits, courseId, semester];
}
