// UI-specific models for the session details screen

class AttendanceStats {
  final int total;
  final int present;
  final int absent;

  AttendanceStats({
    required this.total,
    required this.present,
    required this.absent,
  });

  factory AttendanceStats.empty() {
    return AttendanceStats(total: 0, present: 0, absent: 0);
  }

  double get presentPercentage => total > 0 ? (present / total) * 100 : 0;
  double get absentPercentage => total > 0 ? (absent / total) * 100 : 0;
}

class AttendanceRecord {
  final String id;
  final String studentId;
  final String studentName;
  final bool isPresent;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.isPresent,
  });
}