import 'package:equatable/equatable.dart';

class CourseModel extends Equatable {
  final String id;
  final String name;
  final String code;
  final int? durationYears;

  const CourseModel({
    required this.id,
    required this.name,
    required this.code,
    this.durationYears,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final normalized = _normalizeJson(json);
    return CourseModel(
      id: normalized['id'] as String,
      name: normalized['name'] as String,
      code: normalized['code'] as String,
      durationYears: normalized['durationYears'] as int?,
    );
  }

  static Map<String, dynamic> _normalizeJson(Map<String, dynamic> json) {
    return {
      ...json,
      'id': (json['id'] ?? json['_id'] ?? '').toString(),
      'durationYears': json['durationYears'] ?? json['duration_years'],
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'durationYears': durationYears,
    };
  }

  @override
  List<Object?> get props => [id, name, code, durationYears];
}
