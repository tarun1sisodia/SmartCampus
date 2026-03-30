import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../app/bindings/app_bindings.dart';
import '../../../common/utils/constants/text_strings.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import '../controllers/attendance_controller.dart';
import '../../../models/class_model.dart';
import '../../../common/utils/constants/sized.dart';
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
      appBar: AppBar(
        title: Text(
          classModel.subjectName ?? 'Class Attendance',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
            onPressed: () => attendanceController.loadAttendanceSessions(classModel.id),
            icon: const Icon(Iconsax.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSessionDialog(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Iconsax.calendar_add),
        label: const Text('New Session'),
        elevation: 4,
      ),
      body: Obx(() {
        if (attendanceController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => attendanceController.loadAttendanceSessions(classModel.id),
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).cardTheme.color,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Class Info Section
              SliverToBoxAdapter(
                child: _buildClassInfoCard(context),
              ),

              // Sessions List Section
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sessions History',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${attendanceController.attendanceSessions.length} Total',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: TSizes.spaceBtwItems)),

              // Sessions List
              _buildSessionsList(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildClassInfoCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(TSizes.defaultSpace),
      padding: const EdgeInsets.all(TSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                      classModel.subjectName ?? 'Untitled Subject',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${classModel.courseName} • Sem ${classModel.semester}${classModel.section != null ? ' (${classModel.section})' : ''}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Iconsax.book_1, color: Theme.of(context).colorScheme.onPrimary, size: 28),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Row(
            children: [
              _buildInfoChip(
                context,
                icon: Iconsax.people,
                label: '${attendanceController.students.length} Students',
              ),
              const SizedBox(width: TSizes.sm),
              _buildInfoChip(
                context,
                icon: Iconsax.timer_1,
                label: 'Active',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, {required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.onPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
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
              Icon(Iconsax.calendar_1, size: 64, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text('No Sessions Available', style: Theme.of(context).textTheme.titleMedium),
              Text('Start by creating a new session.', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
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
    final formattedDate = DateFormat('EEE, MMM d, yyyy').format(session.date);
    final isToday = DateUtils.isSameDay(session.date, DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () {
          attendanceController.currentSessionId.value = session.id;
          Get.to(() => MarkAttendanceScreen());
        },
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        child: Padding(
          padding: const EdgeInsets.all(TSizes.md),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isToday ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('dd').format(session.date),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isToday ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      DateFormat('MMM').format(session.date).toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isToday ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: TSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (session.startTime != null)
                      Text(
                        '${session.startTime} - ${session.endTime ?? 'Ongoing'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Iconsax.play_circle, color: Theme.of(context).colorScheme.primary),
                tooltip: 'Quick Take',
                onPressed: () {
                  final status = attendanceController.checkSessionStatus(session.id);
                  if (status['isValid'] == false) {
                    TSnackBar.showInfo(message: status['message'], title: 'Session Warning');
                    return;
                  }
                  attendanceController.currentSessionId.value = session.id;
                  Get.to(() => CarouselAttendanceScreen(), binding: CarouselAttendanceBinding());
                },
              ),
              Icon(Iconsax.arrow_right_3, size: 16, color: Theme.of(context).colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TSizes.md),
      child: Center(
        child: attendanceController.isLoadingMoreSessions.value
            ? const CircularProgressIndicator()
            : OutlinedButton(
                onPressed: attendanceController.loadMoreAttendanceSessions,
                child: const Text('Load More Sessions'),
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
        title: const Text('New Attendance Session'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Obx(() => Text(DateFormat('EEEE, MMMM d, yyyy').format(attendanceController.sessionDate.value))),
                trailing: const Icon(Iconsax.calendar),
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
              const SizedBox(height: TSizes.spaceBtwInputFields),
              TextField(
                controller: attendanceController.startTimeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Start Time',
                  suffixIcon: const Icon(Iconsax.clock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(TSizes.inputFieldRadius)),
                ),
                onTap: () async {
                  final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if (pickedTime != null) attendanceController.startTimeController.text = pickedTime.format(context);
                },
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),
              TextField(
                controller: attendanceController.endTimeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'End Time',
                  suffixIcon: const Icon(Iconsax.clock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(TSizes.inputFieldRadius)),
                ),
                onTap: () async {
                  final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if (pickedTime != null) attendanceController.endTimeController.text = pickedTime.format(context);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text(TTexts.cancel, style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => attendanceController.createAttendanceSession(),
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
            child: const Text('Create Session'),
          ),
        ],
      ),
    );
  }
}
