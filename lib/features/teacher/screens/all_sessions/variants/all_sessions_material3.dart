import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/all_sessions_controller.dart';
import '../../controllers/attendance_controller.dart';
import '../carousel_attendance_screen.dart';
import '../../../app/bindings/app_bindings.dart';

class AllSessionsMaterial3 extends StatelessWidget {
  final AllSessionsController controller;
  final attendanceController = Get.find<AttendanceController>();

  AllSessionsMaterial3({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = PatternTokens.get(UIStyle.material3);

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          _buildM3SearchHeader(theme),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.allSessions.isEmpty) {
                return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
              }

              if (controller.filteredSessions.isEmpty) {
                return Center(
                  child: Text('No academic logs found', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                );
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: controller.filteredSessions.length + (controller.isLoadingMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.filteredSessions.length) {
                    return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
                  }
                  final session = controller.filteredSessions[index];
                  return _buildM3SessionCard(session, theme, tokens);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildM3SearchHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SearchBar(
         controller: controller.searchController,
         hintText: 'Search session registry...',
         elevation: WidgetStateProperty.all(0),
         backgroundColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHigh),
         shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
         padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
         leading: const Icon(Iconsax.search_normal, size: 18),
         onChanged: (_) => controller.filterSessions(),
         trailing: [
            IconButton(onPressed: () => {}, icon: const Icon(Iconsax.filter, size: 18)),
         ],
      ),
    );
  }

  Widget _buildM3SessionCard(dynamic session, ThemeData theme, Map<String, dynamic> tokens) {
    final isSelected = controller.selectedSessionIds.contains(session.id);
    final isRunning = controller.isSessionRunning(session);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: isSelected ? BorderSide(color: theme.colorScheme.primary, width: 2) : BorderSide.none,
      ),
      child: ExpansionTile(
        onExpansionChanged: controller.isSelectionMode.value ? (_) => false : null,
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary,
          child: Text(
            DateFormat('d').format(session.date),
            style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w900),
          ),
        ),
        title: Text(
          session.className ?? 'Unnamed Class',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          DateFormat('EEEE, MMM d').format(session.date),
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: isRunning ? theme.colorScheme.primary : theme.colorScheme.error.withOpacity(0.5), shape: BoxShape.circle),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildM3DataLine(theme, 'Subject', session.subjectName ?? 'N/A'),
                _buildM3DataLine(theme, 'Interval', '${session.startTime} - ${session.endTime}'),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () => _onMark(session),
                        icon: const Icon(Iconsax.clipboard_text, size: 16),
                        label: const Text('Open Registry', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      onPressed: () => controller.deleteSession(session.id),
                      icon: const Icon(Iconsax.trash, size: 18),
                      style: IconButton.styleFrom(backgroundColor: theme.colorScheme.errorContainer, foregroundColor: theme.colorScheme.error),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildM3DataLine(ThemeData theme, String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w700)),
          Text(val, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }

  void _onMark(dynamic session) {
     if (!attendanceController.isSessionRunning(session.id)) return;
     attendanceController.currentSessionId.value = session.id;
     Get.to(() => CarouselAttendanceScreen(), binding: CarouselAttendanceBinding());
  }
}
