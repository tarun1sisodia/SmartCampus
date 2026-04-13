import 'package:equatable/equatable.dart';

class AttendanceRecordModel extends Equatable {
  final String studentId;
  final String name;
  final String? rollNumber;
  final String? photoUrl;
  final String status; // 'present', 'absent', 'late', 'pending'

  const AttendanceRecordModel({
    required this.studentId,
    required this.name,
    this.rollNumber,
    this.photoUrl,
    this.status = 'pending',
  });

  AttendanceRecordModel copyWith({String? status}) {
    return AttendanceRecordModel(
      studentId: studentId,
      name: name,
      rollNumber: rollNumber,
      photoUrl: photoUrl,
      status: status ?? this.status,
    );
  }

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      studentId: json['id'] ?? json['studentId'] ?? '',
      name: json['name'] ?? '',
      rollNumber: json['rollNumber'],
      photoUrl: json['photoUrl'] ?? json['avatarUrl'],
      status: json['status'] ?? 'pending',
    );
  }

  @override
  List<Object?> get props => [studentId, name, rollNumber, photoUrl, status];
}
