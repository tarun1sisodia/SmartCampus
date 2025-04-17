import 'package:SmartCampus/app/routes/app_routes.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Classes',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          // Add refresh button here
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Opening create class screen');
          Get.to(() => CreateClassScreen());
        },
        backgroundColor: dark ? TColors.blue : TColors.yellow,
        child: const Icon(Iconsax.add),
      ),
      body: Obx(() {
        print('Building Obx body');
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
              return Card(
                margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                ),
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
                                  '${classItem.courseName} - Year ${classItem.year}${classItem.section != null ? ' (${classItem.section})' : ''}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
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
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    print('Building action button for $label');
    final dark = THelperFunction.isDarkMode(context);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TSizes.buttonRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: TSizes.sm),
          child: Column(
            children: [
              Icon(icon, color: dark ? TColors.yellow : TColors.deepPurple),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  void _showClassOptions(BuildContext context, dynamic classItem) {
    print('Showing options for class ${classItem.id}');
    final dark = THelperFunction.isDarkMode(context);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        decoration: BoxDecoration(
          color: dark ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(TSizes.cardRadiusLg),
            topRight: Radius.circular(TSizes.cardRadiusLg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Iconsax.edit,
                color: dark ? TColors.yellow : TColors.deepPurple,
              ),
              title: const Text('Edit Class'),
              onTap: () {
                print('Opening edit dialog for class ${classItem.id}');
                Get.back();
                _showEditClassDialog(context, classItem);
              },
            ),
            ListTile(
              leading: Icon(Iconsax.trash, color: Colors.red),
              title: const Text('Delete Class'),
              onTap: () {
                print('Opening delete confirmation for class ${classItem.id}');
                Get.back();
                _showDeleteConfirmation(context, classItem);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditClassDialog(BuildContext context, dynamic classItem) {
    print('Showing edit dialog for class ${classItem.id}');
    final dark = THelperFunction.isDarkMode(context);

    classController.yearController.text = classItem.year.toString();
    classController.sectionController.text = classItem.section ?? '';
    classController.selectedSubjectId.value = classItem.subjectId;
    classController.selectedCourseId.value = classItem.courseId;

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Class'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Course',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          TSizes.inputFieldRadius,
                        ),
                      ),
                    ),
                    isExpanded: true,
                    value: classController.selectedCourseId.value,
                    items: classController.courses.map((course) {
                      return DropdownMenuItem<String>(
                        value: course.id,
                        child: Text(
                          course.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        print('Selected course: $value');
                        classController.selectedCourseId.value = value;
                      }
                    },
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                Obx(
                  () => DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          TSizes.inputFieldRadius,
                        ),
                      ),
                    ),
                    isExpanded: true,
                    value: classController.selectedSubjectId.value,
                    items: classController.subjects.map((subject) {
                      return DropdownMenuItem<String>(
                        value: subject.id,
                        child: Text(
                          subject.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        print('Selected subject: $value');
                        classController.selectedSubjectId.value = value;
                      }
                    },
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                TextField(
                  controller: classController.yearController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Year',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        TSizes.inputFieldRadius,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                TextField(
                  controller: classController.sectionController,
                  decoration: InputDecoration(
                    labelText: 'Section (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        TSizes.inputFieldRadius,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: dark ? Colors.white70 : Colors.black54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              print('Attempting to update class ${classItem.id}');
              if (classController.validateClassForm()) {
                classController.updateClass(classItem.id);
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: dark ? TColors.yellow : TColors.deepPurple,
              foregroundColor: dark ? Colors.black : Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic classItem) {
    print('Showing delete confirmation for class ${classItem.id}');
    final dark = THelperFunction.isDarkMode(context);

    Get.dialog(
      AlertDialog(
        title: const Text('Delete Class'),
        content: Text(
          'Are you sure you want to delete "${classItem.subjectName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: dark ? Colors.white70 : Colors.black54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              print('Deleting class ${classItem.id}');
              classController.deleteClass(classItem.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
