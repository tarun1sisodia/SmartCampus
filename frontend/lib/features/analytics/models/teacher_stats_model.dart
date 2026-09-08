import 'package:equatable/equatable.dart';

class TeacherStatsModel extends Equatable {
  final double overallAttendance;
  final List<SubjectStats> subjectBreakdown;
  final List<DailyStats> trend;

  const TeacherStatsModel({
    required this.overallAttendance,
    required this.subjectBreakdown,
    required this.trend,
  });

  factory TeacherStatsModel.fromJson(Map<String, dynamic> json) {
    // Backend v1 returns `{ overallAttendance, subjectWise, totalSessions }`.
    // Normalize into the UI model while keeping forward compatibility.
    final subjectWise = json['subjectWise'] ?? json['subjectBreakdown'] ?? [];
    final trend = json['trend'] ?? [];
    return TeacherStatsModel(
      overallAttendance: (json['overallAttendance'] ?? 0.0).toDouble(),
      subjectBreakdown: (subjectWise as List).map((item) {
        if (item is Map<String, dynamic>) {
          return SubjectStats(
            subjectName: (item['subject'] ?? item['subjectName'] ?? '').toString(),
            attendance: (item['avgAttendance'] ?? item['attendance'] ?? 0.0).toDouble(),
          );
        }
        return SubjectStats(subjectName: '', attendance: 0.0);
      }).toList(),
      trend: (trend as List)
          .map((item) => DailyStats.fromJson(item))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [overallAttendance, subjectBreakdown, trend];
}

class SubjectStats extends Equatable {
  final String subjectName;
  final double attendance;

  const SubjectStats({required this.subjectName, required this.attendance});

  factory SubjectStats.fromJson(Map<String, dynamic> json) {
    return SubjectStats(
      subjectName: json['subjectName'] ?? '',
      attendance: (json['attendance'] ?? 0.0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [subjectName, attendance];
}

class DailyStats extends Equatable {
  final String date;
  final double attendance;

  const DailyStats({required this.date, required this.attendance});

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: json['date'] ?? '',
      attendance: (json['attendance'] ?? 0.0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [date, attendance];
}
