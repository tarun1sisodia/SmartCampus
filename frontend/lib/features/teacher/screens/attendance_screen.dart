import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/text_strings.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import '../controllers/attendance_controller.dart';
import '../../../models/class_model.dart';
import 'carousel_attendance_screen.dart';
import 'mark_attendance_screen.dart';

class AttendanceScreen extends StatelessWidget {
  final ClassModel classModel;
  final attendanceController = Get.put(AttendanceController());

  AttendanceScreen({super.key, required this.classModel});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      attendanceController.setSelectedClass(classModel);
    });

    return Scaffold(
      backgroundColor: TColors.slate50,
      appBar: AppBar(
        title: Text(
          (classModel.subjectName ?? 'CLASS ATTENDANCE').toUpperCase(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
        actions: [
          IconButton(
            onPressed: () => attendanceController.loadAttendanceSessions(classModel.id),
            icon: const Icon(Iconsax.refresh, color: TColors.slate900),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSessionDialog(context),
        backgroundColor: TColors.executiveNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Iconsax.calendar_add, size: 20),
        label: const Text('NEW SESSION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: const BorderSide(color: Colors.white, width: 1.5)),
      ),
      body: Obx(() {
        if (attendanceController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => attendanceController.loadAttendanceSessions(classModel.id),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Class Info Header (Sharp & High Contrast)
              SliverToBoxAdapter(
                child: _buildClassInfoHeader(context),
              ),

              // 2. Section Header
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SESSIONS HISTORY',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5, color: TColors.slate600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: TColors.blue100,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: TColors.executiveNavy, width: 1.0),
                        ),
                        child: Text(
                          '${attendanceController.attendanceSessions.length} TOTAL',
                          style: const TextStyle(color: TColors.executiveNavy, fontWeight: FontWeight.w900, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // 3. Sessions List
              _buildSessionsList(context),
              
              const SliverToBoxAdapter(child: SizedBox(height: 80)), // Space for FAB
            ],
          ),
        );
      }),
    );
  }

  Widget _buildClassInfoHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TColors.executiveNavy,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (classModel.subjectName ?? 'UNTITLED SUBJECT').toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${classModel.courseName} • SEM ${classModel.semester}${classModel.section != null ? ' (${classModel.section})' : ''}'.toUpperCase(),
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                ),
                child: const Icon(Iconsax.book_1, color: Colors.white, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildInfoChip(
                context,
                icon: Iconsax.people,
                label: '${attendanceController.students.length} STUDENTS',
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                context,
                icon: Iconsax.timer_1,
                label: 'ACTIVE STATUS',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, {required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList(BuildContext context) {
    if (attendanceController.attendanceSessions.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.calendar_1, size: 64, color: TColors.slate400),
              const SizedBox(height: 16),
              const Text('NO SESSIONS AVAILABLE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: TColors.slate900)),
              const Text('START BY CREATING A NEW SESSION.', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: TColors.slate600)),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= attendanceController.attendanceSessions.length) {
              return _buildLoadMoreFooter(context);
            }

            final session = attendanceController.attendanceSessions[index];
            return _buildSessionCard(context, session);
          },
          childCount: attendanceController.attendanceSessions.length + (attendanceController.hasMoreSessions.value ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, dynamic session) {
    final formattedDate = DateFormat('EEE, MMM d, yyyy').format(session.date).toUpperCase();
    final isToday = DateUtils.isSameDay(session.date, DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isToday ? TColors.executiveNavy : TColors.slate400, width: 1.5),
      ),
      child: InkWell(
        onTap: () {
          attendanceController.currentSessionId.value = session.id;
          Get.to(() => MarkAttendanceScreen());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: isToday ? TColors.blue100 : TColors.slate50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: isToday ? TColors.executiveNavy : TColors.slate400, width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('dd').format(session.date),
                      style: TextStyle(
                        color: isToday ? TColors.executiveNavy : TColors.slate900,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      DateFormat('MMM').format(session.date).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isToday ? TColors.executiveNavy : TColors.slate600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: TColors.slate900, letterSpacing: -0.5),
                    ),
                    if (session.startTime != null)
                      Text(
                        '${session.startTime} - ${session.endTime ?? 'ONGOING'}'.toUpperCase(),
                        style: const TextStyle(color: TColors.slate600, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Iconsax.play_circle, color: TColors.executiveNavy, size: 28),
                tooltip: 'Quick Take',
                onPressed: () {
                  final status = attendanceController.checkSessionStatus(session.id);
                  if (status['isValid'] == false) {
                    TSnackBar.showInfo(message: status['message'], title: 'SESSION WARNING');
                    return;
                  }
                  attendanceController.currentSessionId.value = session.id;
                  Get.to(() => CarouselAttendanceScreen(), binding: CarouselAttendanceBinding());
                },
              ),
              const Icon(Iconsax.arrow_right_3, size: 20, color: TColors.slate900),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: attendanceController.isLoadingMoreSessions.value
            ? const CircularProgressIndicator()
            : OutlinedButton(
                onPressed: attendanceController.loadMoreAttendanceSessions,
                child: const Text('LOAD MORE SESSIONS'),
              ),
      ),
    );
  }

  void _showCreateSessionDialog(BuildContext context) {
    attendanceController.sessionDate.value = DateTime.now();
    attendanceController.startTimeController.clear();
    attendanceController.endTimeController.clear();

    Get.dialog(
      AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: TColors.executiveNavy, width: 2.0)),
        backgroundColor: TColors.white,
        title: const Text('NEW ATTENDANCE SESSION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: TColors.slate200, width: 1.0))),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('DATE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: TColors.slate600)),
                  subtitle: Obx(() => Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(attendanceController.sessionDate.value).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: TColors.slate900)
                  )),
                  trailing: const Icon(Iconsax.calendar, color: TColors.executiveNavy),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: attendanceController.sessionDate.value,
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (pickedDate != null) attendanceController.sessionDate.value = pickedDate;
                  },
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: attendanceController.startTimeController,
                readOnly: true,
                style: const TextStyle(fontWeight: FontWeight.w800),
                decoration: const InputDecoration(
                  labelText: 'START TIME',
                  suffixIcon: Icon(Iconsax.clock),
                ),
                onTap: () async {
                  final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if (pickedTime != null) attendanceController.startTimeController.text = pickedTime.format(context).toUpperCase();
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: attendanceController.endTimeController,
                readOnly: true,
                style: const TextStyle(fontWeight: FontWeight.w800),
                decoration: const InputDecoration(
                  labelText: 'END TIME',
                  suffixIcon: Icon(Iconsax.clock),
                ),
                onTap: () async {
                  final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if (pickedTime != null) attendanceController.endTimeController.text = pickedTime.format(context).toUpperCase();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text(TTexts.cancel, style: TextStyle(color: TColors.slate600, fontWeight: FontWeight.w900))),
          ElevatedButton(
            onPressed: () => attendanceController.createAttendanceSession(),
            child: const Text('CREATE SESSION'),
          ),
        ],
      ),
    );
  }
}
