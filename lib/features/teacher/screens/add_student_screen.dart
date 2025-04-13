import 'package:attedance__/features/teacher/controllers/student_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../models/class_model.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';

class AddStudentScreen extends StatelessWidget {
  final ClassModel classModel;
  final studentController = Get.put(StudentController());

  AddStudentScreen({super.key, required this.classModel});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    // Set the selected class when the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      studentController.setSelectedClass(classModel);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Students',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.import),
            onPressed: () => _showImportStudentsDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStudentDialog(context),
        backgroundColor: dark ? TColors.blue : TColors.yellow,
        child: const Icon(Iconsax.add),
      ),
      body: Obx(() {
        if (studentController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (studentController.students.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.people,
                  size: 64,
                  color: dark ? TColors.yellow : TColors.deepPurple,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(
                  'No Students Yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: TSizes.spaceBtwItems / 2),
                Text(
                  'Add students to this class',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                ElevatedButton.icon(
                  onPressed: () => _showAddStudentDialog(context),
                  icon: const Icon(Iconsax.add),
                  label: const Text('Add Student'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dark ? TColors.yellow : TColors.deepPurple,
                    foregroundColor: dark ? Colors.black : Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          itemCount: studentController.students.length,
          itemBuilder: (context, index) {
            final student = studentController.students[index];
            return Card(
              margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(TSizes.md),
                leading: CircleAvatar(
                  backgroundColor: dark ? TColors.yellow : TColors.deepPurple,
                  child: Text(
                    student.name.substring(0, 1),
                    style: TextStyle(
                      color: dark ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  student.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: TSizes.spaceBtwItems / 2),
                    Text(
                      'Roll Number: ${student.rollNumber}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Iconsax.trash),
                  color: Colors.red,
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Remove Student'),
                        content: const Text(
                          'Are you sure you want to remove this student from the class?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Get.back();
                              studentController.removeStudentFromClass(
                                student.id,
                              );
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
              ),
            );
          },
        );
      }),
    );
  }

  // Show dialog to add a new student
  void _showAddStudentDialog(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    // Reset form controllers
    studentController.nameController.clear();
    studentController.rollNumberController.clear();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Student'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name field
              TextField(
                controller: studentController.nameController,
                decoration: InputDecoration(
                  labelText: 'Student Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      TSizes.inputFieldRadius,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwInputFields),

              // Roll Number field
              TextField(
                controller: studentController.rollNumberController,
                decoration: InputDecoration(
                  labelText: 'Roll Number',
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
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (studentController.nameController.text.trim().isEmpty ||
                  studentController.rollNumberController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please fill in all fields',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              studentController.addStudentToClass();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: dark ? TColors.yellow : TColors.deepPurple,
              foregroundColor: dark ? Colors.black : Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Show dialog to import students
  void _showImportStudentsDialog(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    studentController.fetchAvailableStudents(); // Fetch students from Supabase

    Get.dialog(
      AlertDialog(
        title: const Text('Import Students'),
        content: Container(
          width: double.maxFinite,
          height: 400, // Fixed height to prevent layout errors
          child: Obx(() {
            if (studentController.isFetchingAvailableStudents.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (studentController.availableStudents.isEmpty) {
              return const Text('No students available for import.');
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sorting dropdown
                DropdownButton<String>(
                  value: studentController.sortOption.value,
                  onChanged: (value) {
                    if (value != null) {
                      studentController.sortAvailableStudents(value);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 'name',
                      child: Text('Sort by Name'),
                    ),
                    DropdownMenuItem(
                      value: 'rollNumber',
                      child: Text('Sort by Roll Number'),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwItems),

                // List of available students
                Expanded(
                  child: ListView.builder(
                    itemCount: studentController.availableStudents.length,
                    itemBuilder: (context, index) {
                      final student =
                          studentController.availableStudents[index];
                      // Use Obx here to make each checkbox reactive
                      return Obx(() => CheckboxListTile(
                            value: studentController.selectedStudents
                                .any((s) => s.id == student.id),
                            onChanged: (isSelected) {
                              if (isSelected == true) {
                                studentController.selectStudent(student);
                              } else {
                                studentController.deselectStudent(student);
                              }
                            },
                            title: Text(student.name),
                            subtitle:
                                Text('Roll Number: ${student.rollNumber}'),
                          ));
                    },
                  ),
                ),
              ],
            );
          }),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          Obx(() => ElevatedButton(
                onPressed: studentController.selectedStudents.isEmpty
                    ? null // Disable button if no students selected
                    : () {
                        studentController.importSelectedStudents();
                        Get.back();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: dark ? TColors.yellow : TColors.deepPurple,
                  foregroundColor: dark ? Colors.black : Colors.white,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: Text(
                    'Import (${studentController.selectedStudents.length})'),
              )),
        ],
      ),
    );
  }
}
