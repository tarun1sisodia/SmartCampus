class AttendanceRecordModel {
  final String id;
  final String sessionId;
  final String studentId;
  final String status;
  final String? remarks;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AttendanceRecordModel({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.status,
    this.remarks,
    this.createdAt,
    this.updatedAt,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['id'] ?? '',
      sessionId: json['session_id'],
      studentId: json['student_id'],
      status: json['status'],
      remarks: json['remarks'],
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
      'session_id': sessionId,
      'student_id': studentId,
      'status': status,
      'remarks': remarks,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
