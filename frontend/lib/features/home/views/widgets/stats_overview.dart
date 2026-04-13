import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class StatsOverview extends StatelessWidget {
  final int totalClasses;
  final int totalStudents;
  final double averageAttendance;

  const StatsOverview({
    super.key,
    required this.totalClasses,
    required this.totalStudents,
    required this.averageAttendance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStat('Total Classes', totalClasses.toString()),
              const SizedBox(height: 16),
              _buildStat('Total Students', totalStudents.toString()),
            ],
          ),
          CircularPercentIndicator(
            radius: 50.0,
            lineWidth: 10.0,
            percent: averageAttendance,
            center: Text(
              "${(averageAttendance * 100).toInt()}%",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            footer: const Text(
              "Avg Attendance",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white70),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Colors.white,
            backgroundColor: Colors.white24,
            animation: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
