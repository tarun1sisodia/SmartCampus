import 'package:equatable/equatable.dart';

class SectionModel extends Equatable {
  final String id;
  final String name;
  final String courseId;
  final String semesterId;
  final String? classTeacherId;

  const SectionModel({
    required this.id,
    required this.name,
    required this.courseId,
    required this.semesterId,
    this.classTeacherId,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    final normalized = _normalizeJson(json);
    return SectionModel(
      id: normalized['id'] as String,
      name: normalized['name'] as String,
      courseId: normalized['courseId'] as String,
      semesterId: normalized['semesterId'] as String,
      classTeacherId: normalized['classTeacherId'] as String?,
    );
  }

  static Map<String, dynamic> _normalizeJson(Map<String, dynamic> json) {
    return {
      ...json,
      'id': (json['id'] ?? json['_id'] ?? '').toString(),
      'courseId': json['courseId'] ?? (json['course'] is Map ? json['course']['_id'] : json['course'])?.toString(),
      'semesterId': json['semesterId'] ?? (json['semester'] is Map ? json['semester']['_id'] : json['semester'])?.toString(),
      'classTeacherId': json['classTeacherId'] ?? json['class_teacher_id'],
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'courseId': courseId,
      'semesterId': semesterId,
      'classTeacherId': classTeacherId,
    };
  }

  @override
  List<Object?> get props => [id, name, courseId, semesterId, classTeacherId];
}
