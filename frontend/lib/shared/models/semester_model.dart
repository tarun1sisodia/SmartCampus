import 'package:equatable/equatable.dart';

class SemesterModel extends Equatable {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const SemesterModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    final normalized = _normalizeJson(json);
    return SemesterModel(
      id: normalized['id'] as String,
      name: normalized['name'] as String,
      startDate: DateTime.parse(normalized['startDate'] as String),
      endDate: DateTime.parse(normalized['endDate'] as String),
      isActive: normalized['isActive'] as bool? ?? true,
    );
  }

  static Map<String, dynamic> _normalizeJson(Map<String, dynamic> json) {
    return {
      ...json,
      'id': (json['id'] ?? json['_id'] ?? '').toString(),
      'startDate': json['startDate'] ?? json['start_date'],
      'endDate': json['endDate'] ?? json['end_date'],
      'isActive': json['isActive'] ?? json['is_active'],
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [id, name, startDate, endDate, isActive];
}
