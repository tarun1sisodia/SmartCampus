import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:smart_campus/common/utils/helpers/snackbar_helper.dart';
import '../controllers/calendar_controller.dart';
import '../../../models/attendance_session_model.dart';
import '../../../common/utils/constants/sized.dart';

class CalendarScreen extends StatelessWidget {
  final CalendarController controller = Get.put(CalendarController());

  CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Calendar'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () => _showFilterBottomSheet(context)),
          IconButton(icon: const Icon(Iconsax.refresh), onPressed: () => controller.refreshData()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return _buildLoadingState(context);

        return Column(
          children: [
            _buildActiveSessionsIndicator(context),
            _buildCalendar(context),
            const Divider(height: 1),
            _buildSessionsList(context),
          ],
        );
      }),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Column(
      children: [
        _buildShimmerItem(context, height: 40, margin: 8),
        _buildShimmerItem(context, height: 300, margin: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: 4,
            itemBuilder: (context, index) => _buildShimmerItem(context, height: 100, margin: 4),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerItem(BuildContext context, {required double height, double margin = 0}) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      child: Container(
        margin: EdgeInsets.all(margin),
        height: height,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(TSizes.borderRadiusMd)),
      ),
    );
  }

  Widget _buildActiveSessionsIndicator(BuildContext context) {
    return Obx(() {
      final activeCount = controller.activeSessionsCount.value;
      if (activeCount == 0) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const CircleAvatar(radius: 4, backgroundColor: Colors.green),
            const SizedBox(width: 10),
            Text(
              '$activeCount Live ${activeCount == 1 ? 'Session' : 'Sessions'}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCalendar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() => TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: controller.focusedDay.value,
          calendarFormat: controller.calendarFormat.value,
          selectedDayPredicate: (day) => isSameDay(controller.selectedDay.value, day),
          onDaySelected: (sel, foc) {
            controller.selectedDay.value = sel;
            controller.focusedDay.value = foc;
          },
          onFormatChanged: (f) => controller.calendarFormat.value = f,
          onPageChanged: (f) => controller.focusedDay.value = f,
          eventLoader: (day) => controller.getSessionsForDay(day),
          calendarStyle: CalendarStyle(
            markerDecoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
            todayDecoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.2), shape: BoxShape.circle),
            selectedDecoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
            todayTextStyle: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
          ),
          headerStyle: HeaderStyle(
            formatButtonTextStyle: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
            formatButtonDecoration: BoxDecoration(
              border: Border.all(color: colorScheme.primary),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ));
  }

  Widget _buildSessionsList(BuildContext context) {
    return Obx(() {
      final sessions = controller.getSessionsForDay(controller.selectedDay.value);
      if (sessions.isEmpty) {
        return const Expanded(child: Center(child: Text('No sessions for this day', style: TextStyle(color: Colors.grey))));
      }

      return Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: sessions.length,
          itemBuilder: (context, index) => _buildSessionCard(context, sessions[index]),
        ),
      );
    });
  }

  Widget _buildSessionCard(BuildContext context, AttendanceSessionModel session) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = controller.isSessionActive(session);
    final isMySession = controller.userClasses.any((cls) => cls.id == session.classId);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        side: BorderSide(
          color: isActive ? Colors.green : (isMySession ? colorScheme.primary : colorScheme.outlineVariant),
          width: isActive ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          session.subjectName ?? 'Subject',
          style: TextStyle(fontWeight: FontWeight.bold, color: isMySession ? colorScheme.primary : colorScheme.onSurface),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('${session.courseName ?? ""} | Semester ${session.semester ?? "?"} | Section ${session.section ?? "?"}', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Iconsax.clock, size: 14, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text('${session.startTime} - ${session.endTime}', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
            const SizedBox(height: 8),
            _buildBadge(context, isMySession ? 'MY CLASS' : controller.getTeacherNameForSession(session).toUpperCase(), isMySession ? colorScheme.primary : colorScheme.secondary),
          ],
        ),
        trailing: const Icon(Iconsax.arrow_right_3, size: 16),
        onTap: () => TSnackBar.showInfo(message: 'Session details coming soon!'),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(TSizes.cardRadiusLg)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter Schedule', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: TSizes.lg),
              Obx(() => SwitchListTile(
                    title: const Text('Show All Teachers'),
                    value: controller.showAllSessions.value,
                    onChanged: (v) {
                      controller.showAllSessions.value = v;
                      if (v) controller.showOnlyMyClasses.value = false;
                    },
                  )),
              Obx(() => SwitchListTile(
                    title: const Text('Show Only My Classes'),
                    value: controller.showOnlyMyClasses.value,
                    onChanged: controller.showAllSessions.value ? null : (v) => controller.showOnlyMyClasses.value = v,
                  )),
              const Divider(),
              _buildDropdownFilter(context, 'Course', controller.selectedCourse, controller.availableCourses),
              _buildDropdownFilter(context, 'Semester', controller.selectedSemester, controller.availableSemesters.map((s) => s.toString()).toList(), isInt: true),
              const SizedBox(height: TSizes.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.showAllSessions.value = false;
                    controller.showOnlyMyClasses.value = false;
                    controller.selectedCourse.value = null;
                    controller.selectedSemester.value = null;
                    Get.back();
                  },
                  child: const Text('Reset Filters'),
                ),
              ),
              const SizedBox(height: TSizes.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownFilter(BuildContext context, String label, Rx<dynamic> selected, List<String> items, {bool isInt = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Obx(() => DropdownButton<dynamic>(
                isExpanded: true,
                value: selected.value,
                onChanged: controller.showAllSessions.value ? null : (v) => selected.value = v,
                items: [
                  DropdownMenuItem(value: null, child: Text('All ${label}s')),
                  ...items.map((item) => DropdownMenuItem(value: isInt ? int.parse(item) : item, child: Text(isInt ? 'Semester $item' : item))),
                ],
              )),
        ],
      ),
    );
  }
}
