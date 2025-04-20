import 'package:attedance__/app/routes/app_routes.dart';
import 'package:attedance__/models/class_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
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

  @override
  Widget build(BuildContext context) {
    print('Building ClassListScreen');
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
                  print('Refreshing classes');
                  classController.loadClasses();
                },
                icon: const Icon(Iconsax.refresh),
                tooltip: 'Refresh',
              ),
              const SizedBox(width: TSizes.sm),
              IconButton(
                onPressed: () {
                  print('Navigating to reports');
                  Get.toNamed(AppRoutes.reports);
                },
                icon: const Icon(Iconsax.chart),
                tooltip: 'Reports',
              ),
            ],
          ],
        ),
        floatingActionButton: classController.isSelectionMode.value
            ? null // Hide FAB in selection mode
            : FloatingActionButton(
                onPressed: () {
                  print('Opening create class screen');
                  Get.to(() => CreateClassScreen());
                },
                backgroundColor: dark ? TColors.blue : TColors.yellow,
                child: const Icon(Iconsax.add),
              ),
        body: _buildBody(context, dark),
        // Add bottom action bar when in selection mode
        bottomNavigationBar: classController.isSelectionMode.value
            ? _buildSelectionActionBar(context, dark)
            : null,
      );
    });
  }

  Widget _buildBody(BuildContext context, bool dark) {
    if (classController.isLoading.value) {
      print('Loading classes...');
      return const Center(child: CircularProgressIndicator());
    }

    if (classController.classes.isEmpty) {
      print('No classes found');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.book_1,
              size: 64,
              color: dark ? TColors.yellow : TColors.deepPurple,
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
                print('Opening create class screen from empty state');
                Get.to(() => CreateClassScreen());
              },
              icon: const Icon(Iconsax.add),
              label: const Text('Create Class'),
              style: ElevatedButton.styleFrom(
                backgroundColor: dark ? TColors.yellow : TColors.deepPurple,
                foregroundColor: dark ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        print('Refreshing classes via pull-to-refresh');
        return classController.loadClasses();
      },
      color: dark ? TColors.yellow : TColors.deepPurple,
      backgroundColor: dark ? TColors.darkerGrey : Colors.white,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        itemCount: classController.classes.length,
        itemBuilder: (context, index) {
          print('Building class item at index $index');
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
                        color: dark ? TColors.yellow : TColors.deepPurple,
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
                                dark ? TColors.yellow : TColors.deepPurple,
                            child: Text(
                              classItem.subjectName?.substring(0, 1) ?? 'C',
                              style: TextStyle(
                                color: dark ? Colors.black : Colors.white,
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
                                  '${classItem.courseName} - Semester ${classItem.year}${classItem.section != null ? ' (${classItem.section})' : ''}',
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
                                print(
                                    'Opening options for class ${classItem.id}');
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
                                print(
                                    'Opening students for class ${classItem.id}');
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
                                print(
                                    'Opening attendance for class ${classItem.id}');
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
              color: dark ? TColors.yellow : TColors.deepPurple,
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
                  Navigator.pop(context);
                  print('Edit class ${classItem.id}');
                  Get.to(() => CreateClassScreen());
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.trash, color: Colors.red),
                title: const Text('Delete Class',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  print('Delete class ${classItem.id}');
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

  // Add method for confirming deletion of multiple classes
  void _showDeleteSelectedConfirmation(BuildContext context) {
    final count = classController.selectedClassIds.length;
    print('Showing delete confirmation for $count selected classes');

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
}
