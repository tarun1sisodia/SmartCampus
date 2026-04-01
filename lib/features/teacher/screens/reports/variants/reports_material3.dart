import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/attendance_reports_controller.dart';

class ReportsMaterial3 extends StatelessWidget {
  const ReportsMaterial3({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceReportsController>();
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildM3Header(context, 'ANALYTICS & INSIGHTS'),
          _buildM3Node(
            context,
            title: 'Attendance Summary',
            desc: 'Trends and global overview',
            icon: Iconsax.chart_21,
            color: theme.colorScheme.primary,
            onTap: () => Get.toNamed('/attendance-reports'),
          ),
          _buildM3Node(
            context,
            title: 'Student Performance',
            desc: 'Individual records analysis',
            icon: Iconsax.user_octagon,
            color: theme.colorScheme.secondary,
            onTap: () {},
          ),
          const SizedBox(height: 32),
          _buildM3Header(context, 'DATA EXPORT'),
          _buildM3Node(
            context,
            title: 'Generate PDF Report',
            desc: 'Official digital document',
            icon: Iconsax.document_1,
            color: theme.colorScheme.error,
            onTap: () {},
          ),
          _buildM3Node(
            context,
            title: 'Excel Spreadsheet',
            desc: 'Detailed raw analytics',
            icon: Iconsax.document_cloud,
            color: theme.colorScheme.tertiary,
            onTap: () => controller.exportAttendanceReport(),
          ),
        ],
      ),
    );
  }

  Widget _buildM3Header(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 1)),
    );
  }

  Widget _buildM3Node(BuildContext context, {required String title, required String desc, required IconData icon, required Color color, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(desc, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Icon(Iconsax.arrow_right_3, color: theme.colorScheme.outlineVariant, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
