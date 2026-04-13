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
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5), // emerald-50
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF10B981), width: 1.5),
        ),
        child: Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 12),
            Text(
              '$activeCount LIVE ${activeCount == 1 ? 'SESSION' : 'SESSIONS'}',
              style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF065F46), fontSize: 11, letterSpacing: 0.5),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCalendar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: TColors.slate400, width: 1.5),
      ),
      child: Obx(() => TableCalendar(
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
            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(color: TColors.executiveNavy, borderRadius: BorderRadius.zero),
              todayDecoration: BoxDecoration(color: TColors.blue100, borderRadius: BorderRadius.zero),
              selectedDecoration: BoxDecoration(color: TColors.executiveNavy, borderRadius: BorderRadius.zero),
              todayTextStyle: TextStyle(color: TColors.executiveNavy, fontWeight: FontWeight.w900),
              markerSize: 4.0,
            ),
            headerStyle: const HeaderStyle(
              titleTextStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              formatButtonTextStyle: TextStyle(color: TColors.executiveNavy, fontWeight: FontWeight.w900, fontSize: 11),
              formatButtonDecoration: BoxDecoration(
                border: Border.all(color: TColors.executiveNavy, width: 1.5),
                borderRadius: BorderRadius.zero,
              ),
              formatButtonPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
          )),
    );
  }

  Widget _buildSessionsList(BuildContext context) {
    return Obx(() {
      final sessions = controller.getSessionsForDay(controller.selectedDay.value);
      if (sessions.isEmpty) {
        return const Expanded(
          child: Center(
            child: Text('NO SESSIONS RECORDED FOR THIS DATE', style: TextStyle(color: TColors.slate500, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5))
          ),
        );
      }

      return Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          itemBuilder: (context, index) => _buildSessionCard(context, sessions[index]),
        ),
      );
    });
  }

  Widget _buildSessionCard(BuildContext context, AttendanceSessionModel session) {
    final isActive = controller.isSessionActive(session);
    final isMySession = controller.userClasses.any((cls) => cls.id == session.classId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isActive ? const Color(0xFF10B981) : (isMySession ? TColors.executiveNavy : TColors.slate400),
          width: isActive ? 2 : 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          (session.subjectName ?? 'SUBJECT').toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: isMySession ? TColors.executiveNavy : TColors.slate900, letterSpacing: -0.5),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              '${session.courseName} | SEM ${session.semester} | SEC ${session.section ?? "A"}'.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w800, color: TColors.slate600, fontSize: 11, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Iconsax.clock, size: 14, color: TColors.slate500),
                const SizedBox(width: 8),
                Text('${session.startTime} - ${session.endTime}'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: TColors.slate500)),
              ],
            ),
            const SizedBox(height: 12),
            _buildBadge(context, isMySession ? 'MY CLASS' : controller.getTeacherNameForSession(session).toUpperCase(), isMySession ? TColors.executiveNavy : TColors.slate600),
          ],
        ),
        trailing: const Icon(Iconsax.arrow_right_3, size: 20, color: TColors.slate900),
        onTap: () => TSnackBar.showInfo(message: 'SESSION DETAILS VIEW IN DEVELOPMENT'),
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
