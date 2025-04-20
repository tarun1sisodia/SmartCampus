import 'package:attedance__/features/teacher/controllers/student_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/class_model.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';

class AddStudentScreen extends StatelessWidget {
  final ClassModel classModel;
  final studentController = Get.put(StudentController());

  AddStudentScreen({super.key, required this.classModel}) {
    print('AddStudentScreen initialized with class: ${classModel.toString()}');
  }

  @override
  Widget build(BuildContext context) {
    print('Building AddStudentScreen');
    final dark = THelperFunction.isDarkMode(context);

    // Set the selected class when the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('Setting selected class in post frame callback');
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
            onPressed: () {
              print('Import students button pressed');
              _showImportStudentsDialog(context);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Add student FAB pressed');
          _showAddStudentDialog(context);
        },
        backgroundColor: dark ? TColors.blue : TColors.yellow,
        child: const Icon(Iconsax.add),
      ),
      body: Obx(() {
        print('Building Obx body');
        if (studentController.isLoading.value) {
          print('Loading state: true');
          return const Center(child: CircularProgressIndicator());
        }

        if (studentController.students.isEmpty) {
          print('No students found');
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
                  onPressed: () {
                    print('Add student button pressed');
                    _showAddStudentDialog(context);
                  },
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

        print(
            'Building student list with ${studentController.students.length} students');
        return ListView.builder(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          itemCount: studentController.students.length,
          itemBuilder: (context, index) {
            final student = studentController.students[index];
            print('Building list item for student: ${student.name}');
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
                    print('Delete button pressed for student: ${student.name}');
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Remove Student'),
                        content: const Text(
                          'Are you sure you want to remove this student from the class?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              print('Delete dialog cancelled');
                              Get.back();
                            },
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              print(
                                  'Confirming student deletion: ${student.id}');
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

  void _showAddStudentDialog(BuildContext context) {
    print('Opening add student dialog');
    final dark = THelperFunction.isDarkMode(context);

    studentController.nameController.clear();
    studentController.rollNumberController.clear();
    studentController
        .clearSelectedImage(); // Clear any previously selected image
    print('Form controllers reset');

    Get.dialog(
      AlertDialog(
        title: const Text('Add Student'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Student image selection
              Obx(() => GestureDetector(
                    onTap: () => _showImagePickerOptions(context),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: dark ? TColors.darkerGrey : Colors.grey[200],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: dark ? TColors.yellow : TColors.deepPurple,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: studentController.selectedImage.value != null
                            ? Image.file(
                                studentController.selectedImage.value!,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Iconsax.camera,
                                size: 40,
                                color:
                                    dark ? TColors.yellow : TColors.deepPurple,
                              ),
                      ),
                    ),
                  )),
              const SizedBox(height: TSizes.spaceBtwItems),

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

              // Roll number field
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
          TextButton(
              onPressed: () {
                print('Add student dialog cancelled');
                Get.back();
              },
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              print('Attempting to add student');
              if (studentController.nameController.text.trim().isEmpty ||
                  studentController.rollNumberController.text.trim().isEmpty) {
                print('Validation failed: Empty fields');
                Get.snackbar(
                  'Error',
                  'Please fill in all fields',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              print('Adding student to class');
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

  // Method to show image picker options
  void _showImagePickerOptions(BuildContext context) {
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
                'Add Student Photo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              ListTile(
                leading: Icon(
                  Iconsax.camera,
                  color: dark ? TColors.yellow : TColors.deepPurple,
                ),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  studentController.pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(
                  Iconsax.gallery,
                  color: dark ? TColors.yellow : TColors.deepPurple,
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  studentController.pickImage(ImageSource.gallery);
                },
              ),
              if (studentController.selectedImage.value != null)
                ListTile(
                  leading: const Icon(
                    Iconsax.trash,
                    color: Colors.red,
                  ),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    studentController.clearSelectedImage();
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

  // Update the student list item to show student images
  Widget _buildStudentListItem(
      BuildContext context, bool dark, dynamic student) {
    return Card(
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(TSizes.md),
        leading: student.imageUrl != null && student.imageUrl.isNotEmpty
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: student.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircleAvatar(
                    backgroundColor: dark ? TColors.yellow : TColors.deepPurple,
                    child: const CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => CircleAvatar(
                    backgroundColor: dark ? TColors.yellow : TColors.deepPurple,
                    child: Text(
                      student.name.substring(0, 1),
                      style: TextStyle(
                        color: dark ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            : CircleAvatar(
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
            // Existing delete functionality
          },
        ),
      ),
    );
  }

  void _showImportStudentsDialog(BuildContext context) {
    print('Opening import students dialog');
    final dark = THelperFunction.isDarkMode(context);

    // Add a search controller for filtering students
    final searchController = TextEditingController();

    // Add a semester filter
    final selectedSemester = RxInt(0); // 0 means all semesters

    print('Fetching available students');
    studentController.fetchAvailableStudents();

    Get.dialog(
      AlertDialog(
        title: const Text('Import Students'),
        content: SizedBox(
          width: double.maxFinite,
          height: 500, // Increased height for additional filters
          child: Obx(() {
            print('Building import dialog content');
            if (studentController.isFetchingAvailableStudents.value) {
              print('Fetching available students: Loading');
              return const Center(child: CircularProgressIndicator());
            }

            if (studentController.availableStudents.isEmpty) {
              print('No available students found');
              return const Text('No students available for import.');
            }

            // Filter students based on search text and semester
            final filteredStudents =
                studentController.availableStudents.where((student) {
              // Filter by search text (name or roll number)
              final searchMatch = searchController.text.isEmpty ||
                  student.name
                      .toLowerCase()
                      .contains(searchController.text.toLowerCase()) ||
                  student.rollNumber
                      .toLowerCase()
                      .contains(searchController.text.toLowerCase());

              // Filter by semester (if selected)
              final semesterMatch = selectedSemester.value == 0 ||
                  _getSemesterFromRollNumber(student.rollNumber) ==
                      selectedSemester.value;

              return searchMatch && semesterMatch;
            }).toList();

            print(
                'Building available students list with ${filteredStudents.length} filtered students');
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search field
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search by name or roll number',
                    prefixIcon: const Icon(Iconsax.search_normal),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(TSizes.inputFieldRadius),
                    ),
                  ),
                  onChanged: (_) =>
                      Get.forceAppUpdate(), // Force UI update on search
                ),
                const SizedBox(height: TSizes.spaceBtwItems),

                // Semester filter
                Row(
                  children: [
                    const Text('Filter by Semester:'),
                    const SizedBox(width: TSizes.sm),
                    Expanded(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: selectedSemester.value,
                        onChanged: (value) {
                          if (value != null) {
                            selectedSemester.value = value;
                          }
                        },
                        items: [
                          const DropdownMenuItem(
                            value: 0,
                            child: Text('All Semesters'),
                          ),
                          for (int i = 1; i <= 6; i++)
                            DropdownMenuItem(
                              value: i,
                              child: Text('Semester $i'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwItems),

                // Sorting options
                Row(
                  children: [
                    const Text('Sort by:'),
                    const SizedBox(width: TSizes.sm),
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: studentController.sortOption.value,
                        onChanged: (value) {
                          if (value != null) {
                            print('Sorting students by: $value');
                            studentController.sortAvailableStudents(value);
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'name',
                            child: Text('Name (A-Z)'),
                          ),
                          DropdownMenuItem(
                            value: 'nameDesc',
                            child: Text('Name (Z-A)'),
                          ),
                          DropdownMenuItem(
                            value: 'rollNumber',
                            child: Text('Roll Number (Asc)'),
                          ),
                          DropdownMenuItem(
                            value: 'rollNumberDesc',
                            child: Text('Roll Number (Desc)'),
                          ),
                          DropdownMenuItem(
                            value: 'semester',
                            child: Text('Semester'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwItems),

                // Selection actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        studentController
                            .selectAllFilteredStudents(filteredStudents);
                      },
                      child: const Text('Select All'),
                    ),
                    TextButton(
                      onPressed: () {
                        studentController.deselectAllStudents();
                      },
                      child: const Text('Deselect All'),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwItems),

                // Student list
                Expanded(
                  child: filteredStudents.isEmpty
                      ? const Center(child: Text('No matching students found'))
                      : ListView.builder(
                          itemCount: filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = filteredStudents[index];
                            print(
                                'Building checkbox for student: ${student.name}');

                            // Get semester from roll number for display
                            final semester =
                                _getSemesterFromRollNumber(student.rollNumber);
                            final semesterText =
                                semester > 0 ? 'Semester $semester' : '';

                            return Obx(() => CheckboxListTile(
                                  value: studentController.selectedStudents
                                      .any((s) => s.id == student.id),
                                  onChanged: (isSelected) {
                                    print(
                                        'Student selection changed: ${student.name}, selected: $isSelected');
                                    if (isSelected == true) {
                                      studentController.selectStudent(student);
                                    } else {
                                      studentController
                                          .deselectStudent(student);
                                    }
                                  },
                                  title: Text(student.name),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Roll Number: ${student.rollNumber}'),
                                      if (semesterText.isNotEmpty)
                                        Text(
                                          semesterText,
                                          style: TextStyle(
                                            color: dark
                                                ? TColors.yellow
                                                : TColors.deepPurple,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                  secondary: CircleAvatar(
                                    backgroundColor: dark
                                        ? TColors.yellow
                                        : TColors.deepPurple,
                                    child: Text(
                                      student.name.substring(0, 1),
                                      style: TextStyle(
                                        color:
                                            dark ? Colors.black : Colors.white,
                                      ),
                                    ),
                                  ),
                                  dense: true,
                                ));
                          },
                        ),
                ),
              ],
            );
          }),
        ),
        actions: [
          TextButton(
              onPressed: () {
                print('Import dialog cancelled');
                Get.back();
              },
              child: const Text('Cancel')),
          Obx(() => ElevatedButton(
                onPressed: studentController.selectedStudents.isEmpty
                    ? null
                    : () {
                        print(
                            'Importing ${studentController.selectedStudents.length} students');
                        studentController.importSelectedStudents();
                        Get.back();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: dark ? TColors.yellow : TColors.deepPurple,
                  foregroundColor: dark ? Colors.black : Colors.white,
                ),
                child: Text(
                    'Import (${studentController.selectedStudents.length})'),
              )),
        ],
      ),
    );
  }

// Helper method to extract semester from roll number
// Assuming roll numbers follow a pattern like BCA23001 where:
// - BCA is the program
// - 23 is the year
// - 001 is the sequence number
// We can determine semester based on year and current date
  int _getSemesterFromRollNumber(String rollNumber) {
    try {
      if (rollNumber.length < 5) return 0;

      // Extract the year part (e.g., "23" from "BCA23001")
      final yearPart = rollNumber.substring(3, 5);
      final admissionYear = 2000 + int.parse(yearPart);

      // Calculate current year and month
      final now = DateTime.now();
      final currentYear = now.year;
      final currentMonth = now.month;

      // Calculate years since admission
      int yearsSinceAdmission = currentYear - admissionYear;

      // Calculate semester (2 semesters per year)
      int semester = yearsSinceAdmission * 2;

      // Adjust for current month (assuming semesters start in January and July)
      if (currentMonth >= 7) {
        semester += 1;
      }

      // Ensure semester is within valid range (1-6 for a 3-year program)
      return semester.clamp(1, 6);
    } catch (e) {
      print('Error parsing semester from roll number: $e');
      return 0;
    }
  }
}
