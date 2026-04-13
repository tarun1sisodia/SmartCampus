class OfflineClass {
  final String id;
  final String teacherId;
  final String subjectId;
  final String courseId;
  final int semester;
  final String? section;
  final String? subjectName;
  final String? courseName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isSynced;

  OfflineClass({
    required this.id,
    required this.teacherId,
    required this.subjectId,
    required this.courseId,
    required this.semester,
    this.section,
    this.subjectName,
    this.courseName,
    required this.createdAt,
    this.updatedAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacher_id': teacherId,
      'subject_id': subjectId,
      'course_id': courseId,
      'semester': semester,
      'section': section,
      'subject_name': subjectName,
      'course_name': courseName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory OfflineClass.fromMap(Map<String, dynamic> map) {
    return OfflineClass(
      id: map['id'],
      teacherId: map['teacher_id'],
      subjectId: map['subject_id'],
      courseId: map['course_id'],
      semester: map['semester'],
      section: map['section'],
      subjectName: map['subject_name'],
      courseName: map['course_name'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      isSynced: map['is_synced'] == 1,
    );
  }
}

class OfflineStudent {
  final String id;
  final String name;
  final String rollNumber;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isSynced;

  OfflineStudent({
    required this.id,
    required this.name,
    required this.rollNumber,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'roll_number': rollNumber,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory OfflineStudent.fromMap(Map<String, dynamic> map) {
    return OfflineStudent(
      id: map['id'],
      name: map['name'],
      rollNumber: map['roll_number'],
      imageUrl: map['image_url'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      isSynced: map['is_synced'] == 1,
    );
  }
}

class OfflineAttendanceSession {
  final String id;
  final String classId;
  final DateTime date;
  final String? startTime;
  final String? endTime;
  final String status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isSynced;

  OfflineAttendanceSession({
    required this.id,
    required this.classId,
    required this.date,
    this.startTime,
    this.endTime,
    this.status = 'open',
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'class_id': classId,
      'date': date.toIso8601String().split('T')[0], // Date only
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory OfflineAttendanceSession.fromMap(Map<String, dynamic> map) {
    return OfflineAttendanceSession(
      id: map['id'],
      classId: map['class_id'],
      date: DateTime.parse(map['date']),
      startTime: map['start_time'],
      endTime: map['end_time'],
      status: map['status'] ?? 'open',
      createdBy: map['created_by'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      isSynced: map['is_synced'] == 1,
    );
  }
}

class OfflineAttendanceRecord {
  final String id;
  final String sessionId;
  final String studentId;
  final String status;
  final String? remarks;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isSynced;

  OfflineAttendanceRecord({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.status,
    this.remarks,
    required this.createdAt,
    this.updatedAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'student_id': studentId,
      'status': status,
      'remarks': remarks,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory OfflineAttendanceRecord.fromMap(Map<String, dynamic> map) {
    return OfflineAttendanceRecord(
      id: map['id'],
      sessionId: map['session_id'],
      studentId: map['student_id'],
      status: map['status'],
      remarks: map['remarks'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      isSynced: map['is_synced'] == 1,
    );
  }
}