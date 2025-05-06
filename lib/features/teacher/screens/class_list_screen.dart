import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/routes/app_routes.dart';
import '../../../models/class_model.dart';
import '../../../models/course_model.dart';
import '../../../models/subject_model.dart';
import '../controllers/class_controller.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';
import 'add_student_screen.dart';
import 'attendance_screen.dart';
import 'create_class_screen.dart'; // Ensure this import points to the correct file

class ClassListScreen extends StatelessWidget {
  final classController = Get.put(ClassController());

  ClassListScreen({super.key});

  // Modify your Scaffold in the build method to use a conditional FAB
  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            classController.isSelectionMode.value
                ? '${classController.selectedClassIds.length} Selected'
                : 'My Classes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          leading: classController.isSelectionMode.value
              ? IconButton(
                  onPressed: () {
                    classController.toggleSelectionMode(null);
                  },
                  icon: const Icon(Icons.close),
                )
              : null,
          actions: [
            // Show select all button in selection mode
            if (classController.isSelectionMode.value)
              IconButton(
                onPressed: () {
                  classController.toggleSelectAll();
                },
                icon: Icon(
                  classController.isAllSelected.value
                      ? Icons.select_all
                      : Icons.select_all_outlined,
                ),
              ),
            // Show normal actions when not in selection mode
            if (!classController.isSelectionMode.value) ...[
              IconButton(
                onPressed: () {
                  classController.loadClasses();
                },
                icon: const Icon(Iconsax.refresh),
                tooltip: 'Refresh',
              ),
              const SizedBox(width: TSizes.sm),
              IconButton(
                onPressed: () {
                  Get.toNamed(AppRoutes.reports);
                },
                icon: const Icon(Iconsax.chart),
                tooltip: 'Reports',
              ),
            ],
          ],
        ),
        // Only show FAB when not in selection mode AND not loading
        floatingActionButton: (!classController.isSelectionMode.value &&
                !classController.isLoading.value)
            ? AnimatedOpacity(
                opacity: classController.isLoading.value ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Get.to(() => CreateClassScreen());
                  },
                  backgroundColor: dark ? TColors.blue : TColors.yellow,
                  icon: const Icon(Iconsax.book_square),
                  label: const Text('Create Class'),
                ),
              )
            : null,
        body: _buildBody(context, dark),
        bottomNavigationBar: classController.isSelectionMode.value
            ? _buildSelectionActionBar(context, dark)
            : null,
      );
    });
  }

  // Inside the _buildBody method, replace the existing loading UI with this enhanced version:

  Widget _buildBody(BuildContext context, bool dark) {
    if (classController.isLoading.value) {
      return Column(
        children: [
          // // AppBar shimmer
          // Padding(
          //   padding: const EdgeInsets.symmetric(
          //     horizontal: TSizes.defaultSpace,
          //     vertical: TSizes.sm,
          //   ),
          //   child: Shimmer.fromColors(
          //     baseColor: dark ? TColors.darkerGrey : Colors.grey.shade300,
          //     highlightColor: dark ? TColors.yellow : TColors.primary,
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         // Title shimmer
          //         Container(
          //           height: 24,
          //           width: 120,
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             borderRadius: BorderRadius.circular(4),
          //           ),
          //         ),
          //         // Action buttons shimmer
          //         Row(
          //           children: [
          //             Container(
          //               width: 40,
          //               height: 40,
          //               decoration: BoxDecoration(
          //                 color: Colors.white,
          //                 shape: BoxShape.circle,
          //               ),
          //             ),
          //             const SizedBox(width: TSizes.sm),
          //             Container(
          //               width: 40,
          //               height: 40,
          //               decoration: BoxDecoration(
          //                 color: Colors.white,
          //                 shape: BoxShape.circle,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          // // Divider shimmer
          // Shimmer.fromColors(
          //   baseColor: dark ? TColors.darkerGrey : Colors.grey.shade300,
          //   highlightColor: dark ? TColors.yellow : TColors.primary,
          //   child: Container(
          //     height: 1,
          //     width: double.infinity,
          //     color: Colors.white,
          //   ),
          // ),

          // Class cards shimmer
          Expanded(
            child: ListView.builder(
              itemCount: 6, // Number of shimmer items to display
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TSizes.defaultSpace,
                    vertical: TSizes.spaceBtwItems / 2,
                  ),
                  child: Shimmer.fromColors(
                    baseColor: dark ? TColors.darkerGrey : Colors.grey.shade300,
                    highlightColor: dark ? TColors.yellow : TColors.primary,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(TSizes.cardRadiusMd),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(TSizes.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Circle avatar shimmer
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: TSizes.spaceBtwItems),
                                // Class title and subtitle shimmer
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 16,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 14,
                                        width: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Options button shimmer
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: TSizes.spaceBtwItems),
                            // Divider shimmer
                            Container(
                              height: 1,
                              width: double.infinity,
                              color: Colors.white,
                            ),
                            const SizedBox(height: TSizes.spaceBtwItems),
                            // Action buttons shimmer
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  height: 40,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                        TSizes.buttonRadius),
                                  ),
                                ),
                                Container(
                                  height: 40,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                        TSizes.buttonRadius),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Floating action button shimmer
          Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Shimmer.fromColors(
                baseColor: dark ? TColors.darkerGrey : Colors.grey.shade300,
                highlightColor: dark ? TColors.yellow : TColors.primary,
                child: Container(
                  width: 180,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (classController.classes.isEmpty) {
      ////print('No classes found');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.book_1,
              size: 64,
              color: dark ? TColors.yellow : TColors.primary,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              'No Classes Yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            Text(
              'Create your first class to get started',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            ElevatedButton.icon(
              onPressed: () {
                ////print('Opening create class screen from empty state');
                Get.to(() => CreateClassScreen());
              },
              icon: const Icon(Iconsax.add),
              label: const Text('Create Class'),
              style: ElevatedButton.styleFrom(
                backgroundColor: dark ? TColors.yellow : TColors.primary,
                foregroundColor: dark ? TColors.dark : Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        ////print('Refreshing classes via pull-to-refresh');
        return classController.loadClasses();
      },
      color: dark ? TColors.yellow : TColors.primary,
      backgroundColor: dark ? TColors.darkerGrey : Colors.white,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        itemCount: classController.classes.length,
        itemBuilder: (context, index) {
          ////print('Building class item at index $index');
          final classItem = classController.classes[index];

          // Check if this class is selected
          final isSelected =
              classController.selectedClassIds.contains(classItem.id);

          return GestureDetector(
            onLongPress: () {
              // Enter selection mode on long press
              if (!classController.isSelectionMode.value) {
                classController.toggleSelectionMode(classItem.id);
              }
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                // Add border when selected
                side: isSelected
                    ? BorderSide(
                        color: dark ? TColors.yellow : TColors.primary,
                        width: 2,
                      )
                    : BorderSide.none,
              ),
              child: InkWell(
                onTap: () {
                  // Toggle selection if in selection mode, otherwise do nothing
                  if (classController.isSelectionMode.value) {
                    classController.toggleClassSelection(classItem.id);
                  }
                },
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                child: Padding(
                  padding: const EdgeInsets.all(TSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                dark ? TColors.yellow : TColors.primary,
                            child: Text(
                              classItem.subjectName?.substring(0, 1) ?? 'C',
                              style: TextStyle(
                                color: dark ? TColors.dark : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: TSizes.spaceBtwItems),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  classItem.subjectName ?? 'Unknown Subject',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${classItem.courseName} - Semester ${classItem.semester}${classItem.section != null ? ' (${classItem.section})' : ''}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          // Only show options button when not in selection mode
                          if (!classController.isSelectionMode.value)
                            IconButton(
                              icon: const Icon(Iconsax.more),
                              onPressed: () {
                                ////print(
                                // 'Opening options for class ${classItem.id}');
                                _showClassOptions(context, classItem);
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      const Divider(),
                      // Only show action buttons when not in selection mode
                      if (!classController.isSelectionMode.value)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              context,
                              icon: Iconsax.people,
                              label: 'Students',
                              onTap: () {
                                ////print(
                                // 'Opening students for class ${classItem.id}');
                                Get.to(() =>
                                    AddStudentScreen(classModel: classItem));
                              },
                              dark: dark, // Pass the dark parameter here
                            ),
                            _buildActionButton(
                              context,
                              icon: Iconsax.calendar_1,
                              label: 'Attendance',
                              onTap: () {
                                ////print(
                                // 'Opening attendance for class ${classItem.id}');
                                Get.to(() =>
                                    AttendanceScreen(classModel: classItem));
                              },
                              dark: dark, // Pass the dark parameter here
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Add bottom action bar for selection mode
  Widget _buildSelectionActionBar(BuildContext context, bool dark) {
    return BottomAppBar(
      color: dark ? TColors.darkerGrey : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${classController.selectedClassIds.length} selected',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ElevatedButton.icon(
              onPressed: classController.selectedClassIds.isEmpty
                  ? null
                  : () {
                      _showDeleteSelectedConfirmation(context);
                    },
              icon: const Icon(Iconsax.trash),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool dark, // Add this parameter
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TSizes.md,
          vertical: TSizes.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: dark ? TColors.yellow : TColors.primary,
            ),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }

  void _showClassOptions(BuildContext context, ClassModel classItem) {
    final dark = THelperFunction.isDarkMode(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(TSizes.cardRadiusLg),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Class Options',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              ListTile(
                leading: const Icon(Iconsax.edit),
                title: const Text('Edit Class'),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  ////print('Edit class ${classItem.id}');
                  _showEditClassDialog(context, classItem);
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.trash, color: Colors.red),
                title: const Text('Delete Class',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  ////print('Delete class ${classItem.id}');
                  _showDeleteConfirmation(context, classItem);
                },
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dark ? Colors.grey[800] : Colors.grey[200],
                    foregroundColor: dark ? Colors.white : TColors.dark,
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

  void _showDeleteConfirmation(BuildContext context, ClassModel classItem) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Class'),
          content: Text(
              'Are you sure you want to delete "${classItem.subjectName}"? This will also delete all attendance sessions and records for this class.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                classController.deleteClass(classItem.id);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  //confirming deletion of multiple classes
  void _showDeleteSelectedConfirmation(BuildContext context) {
    final count = classController.selectedClassIds.length;
    ////print('Showing delete confirmation for $count selected classes');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Selected Classes'),
          content: Text(
              'Are you sure you want to delete $count selected ${count == 1 ? 'class' : 'classes'}? This will also delete all attendance sessions and records for ${count == 1 ? 'this class' : 'these classes'}.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                classController.deleteSelectedClasses();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditClassDialog(BuildContext context, ClassModel classItem) {
    final dark = THelperFunction.isDarkMode(context);

    // Load the class data into the controller
    classController.loadClassForEditing(classItem);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Class'),
          content: SingleChildScrollView(
            child: Obx(() {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Subject Dropdown
                  DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(TSizes.inputFieldRadius),
                      ),
                    ),
                    isExpanded: true,
                    value: classController.selectedSubject.value,
                    items: classController.subjects.map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text(
                          subject.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      classController.selectedSubject.value = value;
                      if (value != null) {
                        classController.selectedSubjectId.value =
                            (value as SubjectModel).id;
                      }
                    },
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),

                  // Course Dropdown
                  DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: 'Course',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(TSizes.inputFieldRadius),
                      ),
                    ),
                    isExpanded: true,
                    value: classController.selectedCourse.value,
                    items: classController.courses.map((course) {
                      return DropdownMenuItem(
                        value: course,
                        child: Text(
                          course.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      classController.selectedCourse.value =
                          value as CourseModel?;
                      if (value != null) {
                        classController.selectedCourseId.value = value.id;
                      }
                    },
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),

                  // Semester TextField
                  TextFormField(
                    controller: classController.semesterController,
                    decoration: InputDecoration(
                      labelText: 'Semester',
                      hintText: 'Enter semester (1-6)',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(TSizes.inputFieldRadius),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      FilteringTextInputFormatter.allow(RegExp(r'^[1-6]')),
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),

                  // Section TextField
                  TextFormField(
                    controller: classController.sectionController,
                    decoration: InputDecoration(
                      labelText: 'Section (Optional)',
                      hintText: 'Enter section (e.g., A, B, C)',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(TSizes.inputFieldRadius),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Update the class
                classController.updateClass(classItem.id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: dark ? TColors.yellow : TColors.primary,
                foregroundColor: dark ? TColors.dark : Colors.white,
              ),
              child: Text('Update Class'),
            ),
          ],
        );
      },
    );
  }
}
