class AttendanceStatsModel {
  final int totalStudents;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int excusedCount;
  final int unmarkedCount;
  
  AttendanceStatsModel({
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.excusedCount,
  }) : unmarkedCount = totalStudents - (presentCount + absentCount + lateCount + excusedCount);
  
  double get presentPercentage => 
      totalStudents > 0 ? (presentCount / totalStudents) * 100 : 0;
      
  double get absentPercentage => 
      totalStudents > 0 ? (absentCount / totalStudents) * 100 : 0;
      
  double get latePercentage => 
      totalStudents > 0 ? (lateCount / totalStudents) * 100 : 0;
      
  double get excusedPercentage => 
      totalStudents > 0 ? (excusedCount / totalStudents) * 100 : 0;
      
  double get unmarkedPercentage => 
      totalStudents > 0 ? (unmarkedCount / totalStudents) * 100 : 0;
}
