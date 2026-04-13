import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../common/utils/constants/colors.dart';

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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TColors.slate900,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: TColors.executiveNavy, width: 2.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStat('TOTAL CLASSES', totalClasses.toString()),
                const SizedBox(height: 24),
                _buildStat('TOTAL STUDENTS', totalStudents.toString()),
              ],
            ),
          ),
          CircularPercentIndicator(
            radius: 54.0,
            lineWidth: 16.0,
            percent: averageAttendance,
            center: Text(
              "${(averageAttendance * 100).toInt()}%",
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.white),
            ),
            footer: const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                "AVG ATTENDANCE",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.white70, letterSpacing: 0.5),
              ),
            ),
            circularStrokeCap: CircularStrokeCap.butt, //butt is sharp
            progressColor: TColors.cyan400,
            backgroundColor: Colors.white.withOpacity(0.1),
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
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
      ],
    );
  }
}
