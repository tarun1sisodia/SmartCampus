import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';

class AttendanceStatsCard extends StatelessWidget {
  final int totalStudents;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int excusedCount;
  final bool isCompact;

  AttendanceStatsCard({
    super.key,
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.excusedCount,
    this.isCompact = false,
  }) {
    //print('AttendanceStatsCard initialized with:');
    //print('Total Students: $totalStudents');
    //print('Present Count: $presentCount');
    //print('Absent Count: $absentCount');
    //print('Late Count: $lateCount');
    //print('Excused Count: $excusedCount');
    //print('Is Compact: $isCompact');
  }

  @override
  Widget build(BuildContext context) {
    //print('Building AttendanceStatsCard');
    final dark = THelperFunction.isDarkMode(context);
    final unmarkedCount =
        totalStudents - (presentCount + absentCount + lateCount + excusedCount);
    //print('Dark mode: $dark');
    //print('Unmarked count: $unmarkedCount');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Summary',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: TSizes.spaceBtwItems),

            // Progress indicator
            LinearProgressIndicator(
              value: totalStudents > 0
                  ? (totalStudents - unmarkedCount) / totalStudents
                  : 0,
              backgroundColor: Colors.grey.withAlpha(51),
              valueColor: AlwaysStoppedAnimation<Color>(
                dark ? TColors.yellow : TColors.primary,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),

            const SizedBox(height: TSizes.spaceBtwItems / 2),

            Text(
              'Marked: ${totalStudents - unmarkedCount}/$totalStudents students',
              style: Theme.of(context).textTheme.bodySmall,
            ),

            const SizedBox(height: TSizes.spaceBtwItems),

            // Stats grid
            Row(
              children: [
                _buildStatItem(
                  context,
                  'Present',
                  presentCount,
                  Colors.green,
                  Iconsax.tick_circle,
                ),
                _buildStatItem(
                  context,
                  'Absent',
                  absentCount,
                  Colors.red,
                  Iconsax.close_circle,
                ),
                _buildStatItem(
                  context,
                  'Late',
                  lateCount,
                  Colors.orange,
                  Iconsax.timer_1,
                ),
                _buildStatItem(
                  context,
                  'Excused',
                  excusedCount,
                  Colors.blue,
                  Iconsax.note_1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    //print('Building stat item: $label with count: $count');
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
