import 'package:equatable/equatable.dart';

class StudentDetailModel extends Equatable {
  const StudentDetailModel({
    required this.id,
    required this.name,
    required this.rollNumber,
    this.photoUrl,
    this.email,
    this.contact,
    this.parentContact,
    this.address,
    this.enrollmentYear,
    this.isActive = true,
    this.course,
    this.semester,
    this.section,
  });

  final String id;
  final String name;
  final String rollNumber;
  final String? photoUrl;
  final String? email;
  final String? contact;
  final String? parentContact;
  final String? address;
  final int? enrollmentYear;
  final bool isActive;
  final String? course;
  final String? semester;
  final String? section;

  factory StudentDetailModel.fromJson(Map<String, dynamic> json) {
    final normalized = _normalizeJson(json);
    return StudentDetailModel(
      id: normalized['id'] as String,
      name: normalized['name'] as String,
      rollNumber: normalized['rollNumber'] as String,
      photoUrl: normalized['photoUrl'] as String?,
      email: normalized['email'] as String?,
      contact: normalized['contact'] as String?,
      parentContact: normalized['parentContact'] as String?,
      address: normalized['address'] as String?,
      enrollmentYear: normalized['enrollmentYear'] as int?,
      isActive: normalized['isActive'] as bool? ?? true,
      course: normalized['course']?.toString(),
      semester: normalized['semester']?.toString(),
      section: normalized['section']?.toString(),
    );
  }

  static Map<String, dynamic> _normalizeJson(Map<String, dynamic> json) {
    return {
      ...json,
      'id': (json['id'] ?? json['_id'] ?? '').toString(),
      'rollNumber': (json['rollNumber'] ?? json['roll_number'] ?? '').toString(),
      'photoUrl': json['photoUrl'] ?? json['photo'] ?? json['avatarUrl'] ?? json['image_url'],
      'enrollmentYear': json['enrollmentYear'] ?? json['enrollment_year'],
      'parentContact': json['parentContact'] ?? json['parent_contact'],
      'isActive': json['isActive'] ?? json['is_active'] ?? true,
      'course': json['courseName'] ?? (json['course'] is Map ? json['course']['name'] : json['course']),
      'semester': json['semesterName'] ?? (json['semester'] is Map ? json['semester']['name'] : json['semester']),
      'section': json['sectionName'] ?? (json['section'] is Map ? json['section']['name'] : json['section']),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        rollNumber,
        photoUrl,
        email,
        contact,
        parentContact,
        address,
        enrollmentYear,
        isActive,
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
