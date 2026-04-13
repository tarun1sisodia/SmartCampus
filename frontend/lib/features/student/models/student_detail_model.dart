import 'package:equatable/equatable.dart';

class StudentDetailModel extends Equatable {
  const StudentDetailModel({
    required this.id,
    required this.name,
    required this.rollNumber,
    this.photoUrl,
    this.contact,
    this.parentContact,
    this.course,
    this.semester,
    this.section,
  });

  final String id;
  final String name;
  final String rollNumber;
  final String? photoUrl;
  final String? contact;
  final String? parentContact;
  final String? course;
  final int? semester;
  final String? section;

  factory StudentDetailModel.fromJson(Map<String, dynamic> json) {
    return StudentDetailModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      rollNumber: (json['rollNumber'] ?? '').toString(),
      photoUrl: (json['photoUrl'] ?? json['avatarUrl'])?.toString(),
      contact: json['contact']?.toString(),
      parentContact: json['parentContact']?.toString(),
      course: (json['courseName'] ?? json['course']?['name'])?.toString(),
      semester: json['semester'] is int
          ? json['semester'] as int
          : int.tryParse((json['semester'] ?? '').toString()),
      section: json['section']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        rollNumber,
        photoUrl,
        contact,
        parentContact,
        course,
        semester,
        section,
      ];
}

class StudentAttendanceSummary extends Equatable {
  const StudentAttendanceSummary({
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
  });

  final int presentCount;
  final int absentCount;
  final int lateCount;

  int get total => presentCount + absentCount + lateCount;
  double get presentPercentage => total == 0 ? 0 : presentCount / total;

  factory StudentAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceSummary(
      presentCount: _toInt(json['presentCount'] ?? json['present'] ?? 0),
      absentCount: _toInt(json['absentCount'] ?? json['absent'] ?? 0),
      lateCount: _toInt(json['lateCount'] ?? json['late'] ?? 0),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  @override
  List<Object?> get props => [presentCount, absentCount, lateCount];
}
