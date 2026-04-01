import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/session_details_controller.dart';
import '../../../common/utils/constants/sized.dart';

class SessionDetailsMaterial3 extends StatelessWidget {
  final SessionDetailsController controller;
  final Map<String, dynamic> classDetails;

  const SessionDetailsMaterial3({super.key, required this.controller, required this.classDetails});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = PatternTokens.get(UIStyle.material3);

    return Container(
      color: theme.colorScheme.surface,
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
        }

        if (controller.session.value == null) {
          return const Center(child: Text('Session directory corrupted'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildM3Header(theme),
            const SizedBox(height: 16),
            _buildM3StatsCard(theme),
            const SizedBox(height: 16),
            _buildM3ActionRow(theme),
            const SizedBox(height: 24),
            Padding(
               padding: const EdgeInsets.symmetric(horizontal: 8),
               child: Text('Attendee Ledger', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 12),
            _buildM3Roster(theme),
            const SizedBox(height: 64),
          ],
        );
      }),
    );
  }

  Widget _buildM3Header(ThemeData theme) {
    final session = controller.session.value!;
    final isActive = controller.isSessionActive();

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(classDetails['subjectName'] ?? 'Academic Module', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900))),
                if (isActive)
                   Badge(
                     label: const Text('LIVE'),
                     backgroundColor: theme.colorScheme.primary,
                     padding: const EdgeInsets.symmetric(horizontal: 12),
                   ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${classDetails['courseName']} • Section ${classDetails['section']}', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildM3InfoChip(theme, Iconsax.calendar_1, controller.formatDate(session.date)),
                const SizedBox(width: 8),
                _buildM3InfoChip(theme, Iconsax.clock, '${session.startTime} - ${session.endTime}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildM3InfoChip(ThemeData theme, IconData icon, String val) {
    return Container(
       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
       decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerLowest, borderRadius: BorderRadius.circular(12)),
       child: Row(
         children: [
           Icon(icon, size: 14, color: theme.colorScheme.primary),
           const SizedBox(width: 8),
           Text(val, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800)),
         ],
       ),
    );
  }

  Widget _buildM3StatsCard(ThemeData theme) {
    final stats = controller.attendanceStats.value;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildM3StatItem(theme, 'TOTAL', stats.total, theme.colorScheme.onSurface),
                _buildM3StatItem(theme, 'PRESENT', stats.present, theme.colorScheme.primary),
                _buildM3StatItem(theme, 'ABSENT', stats.absent, theme.colorScheme.error),
              ],
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: stats.presentPercentage / 100,
              backgroundColor: theme.colorScheme.surfaceContainerHigh,
              color: theme.colorScheme.primary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildM3StatItem(ThemeData theme, String label, int val, Color color) {
    return Column(
      children: [
        Text('$val', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: color)),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildM3ActionRow(ThemeData theme) {
    final isActive = controller.isSessionActive();
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: isActive ? controller.generateQRCode : null,
            icon: const Icon(Iconsax.scan, size: 16),
            label: const Text('Generation QR'),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: controller.exportAttendanceData,
            icon: const Icon(Iconsax.document_download, size: 16),
            label: const Text('Export Ledger'),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          ),
        ),
      ],
    );
  }

  Widget _buildM3Roster(ThemeData theme) {
    final records = controller.attendanceRecords;
    if (records.isEmpty) {
      return Center(child: Text('No attendance records identified', style: theme.textTheme.labelLarge));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
           elevation: 0,
           margin: const EdgeInsets.only(bottom: 8),
           color: theme.colorScheme.surfaceContainerLowest,
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: theme.colorScheme.outlineVariant)),
           child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                 backgroundColor: record.isPresent ? theme.colorScheme.primaryContainer : theme.colorScheme.errorContainer,
                 child: Icon(record.isPresent ? Icons.check : Icons.close, color: record.isPresent ? theme.colorScheme.primary : theme.colorScheme.error, size: 20),
              ),
              title: Text(record.studentName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              subtitle: Text('ID: ${record.studentId}', style: theme.textTheme.labelSmall),
              trailing: controller.isSessionActive() 
                 ? Switch(value: record.isPresent, onChanged: (v) => controller.toggleAttendance(record.id, v))
                 : null,
           ),
        );
      },
    );
  }
}
