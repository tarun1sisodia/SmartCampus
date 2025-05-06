import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';
import '../../../models/student_model.dart';
import '../controllers/student_detail_controller.dart';

class StudentDetailScreen extends StatelessWidget {
  final StudentModel student;
  final String classId;
  final studentDetailController = Get.put(StudentDetailController());

  StudentDetailScreen({
    super.key,
    required this.student,
    required this.classId,
  }) {
    //print(
    // 'Initializing StudentDetailScreen with student: $student and classId: $classId');
    // Initialize controller with student and class data
    studentDetailController.setStudentAndClass(student, classId);
  }

  @override
  Widget build(BuildContext context) {
    //print('Building StudentDetailScreen');
    final dark = THelperFunction.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Student Details',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
            onPressed: () {
              //print('Refreshing student data');
              studentDetailController.loadStudentData();
            },
            icon: const Icon(Iconsax.refresh),
          ),
        ],
      ),
      body: Obx(() {
        //print('StudentDetailController state updated');
        if (studentDetailController.isLoading.value) {
          //print('Loading student data...');
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student profile card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(TSizes.md),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Student image with edit option
                          GestureDetector(
                            onTap: () => _showImageOptions(context),
                            child: Stack(
                              children: [
                                // Student image or placeholder
                                Obx(() {
                                  final currentStudent =
                                      studentDetailController.student.value;
                                  final hasImage =
                                      currentStudent?.imageUrl != null &&
                                          currentStudent!.imageUrl!.isNotEmpty;

                                  return Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: dark
                                          ? TColors.darkerGrey
                                          : Colors.grey[200],
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: dark
                                            ? TColors.yellow
                                            : TColors.primary,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: hasImage
                                          ? CachedNetworkImage(
                                              imageUrl:
                                                  currentStudent.imageUrl!,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                              errorWidget:
                                                  (context, url, error) => Icon(
                                                Iconsax.user,
                                                size: 40,
                                                color: dark
                                                    ? TColors.yellow
                                                    : TColors.primary,
                                              ),
                                            )
                                          : Icon(
                                              Iconsax.user,
                                              size: 40,
                                              color: dark
                                                  ? TColors.yellow
                                                  : TColors.primary,
                                            ),
                                    ),
                                  );
                                }),

                                // Edit icon overlay
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: dark
                                          ? TColors.yellow
                                          : TColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Iconsax.camera,
                                      size: 16,
                                      color: dark ? Colors.black : Colors.white,
                                    ),
                                  ),
                                ),

                                // Loading indicator when uploading
                                if (studentDetailController
                                    .isImageUploading.value)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: TSizes.spaceBtwItems),

                          // Student info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  studentDetailController.student.value?.name ??
                                      student.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: TSizes.xs),
                                Text(
                                  'Roll Number: ${studentDetailController.student.value?.rollNumber ?? student.rollNumber}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: TSizes.xs),
                                if (studentDetailController.classModel.value !=
                                    null)
                                  Text(
                                    'Class: ${studentDetailController.classModel.value!.subjectName} - ${studentDetailController.classModel.value!.courseName} Semester ${studentDetailController.classModel.value!.semester}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Attendance statistics
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(TSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attendance Statistics',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularPercentIndicator(
                            radius: 80.0,
                            lineWidth: 12.0,
                            animation: true,
                            percent: studentDetailController
                                    .attendancePercentage.value /
                                100,
                            center: Text(
                              '${studentDetailController.attendancePercentage.value.toStringAsFixed(1)}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor:
                                dark ? TColors.yellow : TColors.primary,
                            backgroundColor: dark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                          ),
                        ],
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            context,
                            'Sessions',
                            studentDetailController.totalSessions.toString(),
                            Icons.calendar_today,
                            dark ? TColors.yellow : TColors.primary,
                          ),
                          _buildStatItem(
                            context,
                            'Present',
                            studentDetailController.presentCount.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                          _buildStatItem(
                            context,
                            'Absent',
                            studentDetailController.absentCount.toString(),
                            Icons.cancel,
                            Colors.red,
                          ),
                          _buildStatItem(
                            context,
                            'Late',
                            studentDetailController.lateCount.toString(),
                            Icons.access_time,
                            Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Attendance history
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(TSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attendance History',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      if (studentDetailController.attendanceHistory.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(TSizes.defaultSpace),
                            child: Column(
                              children: [
                                Icon(
                                  Iconsax.calendar_1,
                                  size: 48,
                                  color:
                                      dark ? TColors.yellow : TColors.primary,
                                ),
                                const SizedBox(
                                  height: TSizes.spaceBtwItems / 2,
                                ),
                                Text(
                                  'No attendance records',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount:
                              studentDetailController.attendanceHistory.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final record = studentDetailController
                                .attendanceHistory[index];
                            final session = record['session'];
                            final status = record['status'];
                            final remarks = record['remarks'];

                            //print('Rendering attendance record: $record');

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(status, dark),
                                child: Icon(
                                  _getStatusIcon(status),
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                DateFormat(
                                  'EEEE, MMMM d, yyyy',
                                ).format(session.date),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (session.startTime != null &&
                                      session.endTime != null)
                                    Text(
                                      'Time: ${session.startTime} - ${session.endTime}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  if (remarks != null)
                                    Text(
                                      'Remarks: $remarks',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                ],
                              ),
                              trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status, dark),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status.isNotEmpty
                                        ? status[0].toUpperCase() +
                                            status.substring(1)
                                        : status,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                              onTap: () => _showUpdateStatusDialog(
                                context,
                                session.id,
                                status,
                                remarks,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showImageOptions(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(TSizes.cardRadiusLg)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Update Student Photo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              ListTile(
                leading: Icon(
                  Iconsax.camera,
                  color: dark ? TColors.yellow : TColors.primary,
                ),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  studentDetailController
                      .pickImage(ImageSource.camera)
                      .then((_) {
                    if (studentDetailController.selectedImage.value != null) {
                      studentDetailController.updateStudentImage();
                    }
                  });
                },
              ),
              ListTile(
                leading: Icon(
                  Iconsax.gallery,
                  color: dark ? TColors.yellow : TColors.primary,
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  studentDetailController
                      .pickImage(ImageSource.gallery)
                      .then((_) {
                    if (studentDetailController.selectedImage.value != null) {
                      studentDetailController.updateStudentImage();
                    }
                  });
                },
              ),
              if (studentDetailController.student.value?.imageUrl != null &&
                  studentDetailController.student.value!.imageUrl!.isNotEmpty)
                ListTile(
                  leading: const Icon(
                    Iconsax.trash,
                    color: Colors.red,
                  ),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    // Show confirmation dialog
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Remove Photo'),
                        content: const Text(
                            'Are you sure you want to remove this student\'s photo?'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Get.back();
                              studentDetailController.deleteStudentImage();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: TSizes.spaceBtwItems),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dark ? Colors.grey[800] : Colors.grey[200],
                    foregroundColor: dark ? Colors.white : Colors.black,
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    //print('Building stat item: $label with value: $value');
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Color _getStatusColor(String status, bool dark) {
    //print('Getting status color for status: $status');
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      case 'excused':
        return Colors.blue;
      default:
        return dark ? TColors.yellow : TColors.primary;
    }
  }

  IconData _getStatusIcon(String status) {
    //print('Getting status icon for status: $status');
    switch (status.toLowerCase()) {
      case 'present':
        return Iconsax.tick_circle;
      case 'absent':
        return Iconsax.close_circle;
      case 'late':
        return Iconsax.clock;
      case 'excused':
        return Iconsax.document;
      default:
        return Iconsax.message_question;
    }
  }

  void _showUpdateStatusDialog(
    BuildContext context,
    String sessionId,
    String currentStatus,
    String? currentRemarks,
  ) {
    //print('Showing update status dialog for sessionId: $sessionId');
    final dark = THelperFunction.isDarkMode(context);
    final remarksController = TextEditingController(text: currentRemarks);
    final selectedStatus = currentStatus.obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Update Attendance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status selection
            Text(
              'Select Status:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatusButton(
                    context,
                    'Present',
                    Iconsax.tick_circle,
                    Colors.green,
                    selectedStatus.value.toLowerCase() == 'present',
                    () {
                      //print('Selected status: Present');
                      selectedStatus.value = 'present';
                    },
                  ),
                  _buildStatusButton(
                    context,
                    'Absent',
                    Iconsax.close_circle,
                    Colors.red,
                    selectedStatus.value.toLowerCase() == 'absent',
                    () {
                      //print('Selected status: Absent');
                      selectedStatus.value = 'absent';
                    },
                  ),
                  _buildStatusButton(
                    context,
                    'Late',
                    Iconsax.clock,
                    Colors.orange,
                    selectedStatus.value.toLowerCase() == 'late',
                    () {
                      //print('Selected status: Late');
                      selectedStatus.value = 'late';
                    },
                  ),
                  _buildStatusButton(
                    context,
                    'Excused',
                    Iconsax.document,
                    Colors.blue,
                    selectedStatus.value.toLowerCase() == 'excused',
                    () {
                      //print('Selected status: Excused');
                      selectedStatus.value = 'excused';
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Remarks field
            TextField(
              controller: remarksController,
              decoration: const InputDecoration(
                labelText: 'Remarks (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              //print('Cancelled update attendance');
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              //print(
              // 'Updating attendance record for sessionId: $sessionId with status: ${selectedStatus.value} and remarks: ${remarksController.text}');
              studentDetailController.updateAttendanceRecord(
                sessionId: sessionId,
                status: selectedStatus.value,
                remarks: remarksController.text.isEmpty
                    ? null
                    : remarksController.text,
              );
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: dark ? TColors.yellow : TColors.primary,
              foregroundColor: dark ? Colors.black : Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    //print('Building status button: $label');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
