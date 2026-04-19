import 'package:equatable/equatable.dart';

class AttendanceRecordModel extends Equatable {
  final String studentId;
  final String name;
  final String? rollNumber;
  final String? photoUrl;
  final String status; // 'present', 'absent', 'late', 'pending'
  final String? remarks;
  final DateTime? timestamp;

  const AttendanceRecordModel({
    required this.studentId,
    required this.name,
    this.rollNumber,
    this.photoUrl,
    this.status = 'pending',
    this.remarks,
    this.timestamp,
  });

  AttendanceRecordModel copyWith({String? status, String? remarks}) {
    return AttendanceRecordModel(
      studentId: studentId,
      name: name,
      rollNumber: rollNumber,
      photoUrl: photoUrl,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      timestamp: timestamp,
    );
  }

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    final normalized = _normalizeJson(json);
    return AttendanceRecordModel(
      studentId: normalized['studentId'] as String,
      name: normalized['name'] as String,
      rollNumber: normalized['rollNumber'] as String?,
      photoUrl: normalized['photoUrl'] as String?,
      status: normalized['status'] as String? ?? 'pending',
      remarks: normalized['remarks'] as String?,
      timestamp: normalized['timestamp'] != null ? DateTime.parse(normalized['timestamp'].toString()) : null,
    );
  }

  static Map<String, dynamic> _normalizeJson(Map<String, dynamic> json) {
    return {
      ...json,
      'studentId': (json['studentId'] ?? json['student']?['_id'] ?? json['student']?['id'] ?? json['id'] ?? '').toString(),
      'name': json['name'] ?? json['student']?['name'] ?? '',
      'rollNumber': json['rollNumber'] ?? json['student']?['rollNumber'] ?? json['student']?['roll_number'],
      'photoUrl': json['photoUrl'] ?? json['avatarUrl'] ?? json['photo'] ?? json['student']?['photo'] ?? json['student']?['avatar'],
      'timestamp': json['timestamp'] ?? json['created_at'] ?? json['createdAt'],
    };
  }

  @override
  List<Object?> get props => [studentId, name, rollNumber, photoUrl, status, remarks, timestamp];
}
