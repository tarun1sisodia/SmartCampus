import 'package:smart_campus/features/home/models/session_model.dart';
import 'package:smart_campus/features/attendance/models/attendance_record_model.dart';

class SessionDetailModel extends SessionModel {
  final List<AttendanceRecordModel> attendanceRecords;

  const SessionDetailModel({
    required super.id,
    required super.subjectName,
    required super.section,
    required super.courseId,
    required super.startTime,
    super.endTime,
    required super.totalStudents,
    super.presentCount,
    required super.status,
    this.attendanceRecords = const [],
  });

  factory SessionDetailModel.fromJson(Map<String, dynamic> json) {
    final session = SessionModel.fromJson(json);
    
    var attendanceList = <AttendanceRecordModel>[];
    if (json['attendance'] != null) {
      attendanceList = (json['attendance'] as List)
          .map((i) => AttendanceRecordModel.fromJson(i))
          .toList();
    } else if (json['students'] != null) {
       attendanceList = (json['students'] as List)
          .map((i) => AttendanceRecordModel.fromJson(i))
          .toList();
    }

    return SessionDetailModel(
      id: session.id,
      subjectName: session.subjectName,
      section: session.section,
      courseId: session.courseId,
      startTime: session.startTime,
      endTime: session.endTime,
      totalStudents: session.totalStudents,
      presentCount: session.presentCount,
      status: session.status,
      attendanceRecords: attendanceList,
    );
  }

  @override
  List<Object?> get props => [...super.props, attendanceRecords];
}
