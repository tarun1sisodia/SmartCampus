import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import '../../../common/widgets/student_avatar.dart';
import '../../../models/class_model.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';
import '../controllers/student_controller.dart';

class AddStudentScreen extends StatelessWidget {
  final ClassModel classModel;
  final studentController = Get.put(StudentController());

  AddStudentScreen({super.key, required this.classModel}) {
    //print('AddStudentScreen initialized with class: ${classModel.toString()}');
  }

  @override
  Widget build(BuildContext context) {
    //print('Building AddStudentScreen');
    final dark = THelperFunction.isDarkMode(context);

    // Set the selected class when the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //print('Setting selected class in post frame callback');
      studentController.setSelectedClass(classModel);
    });

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() => AppBar(
              title: studentController.isSelectionMode.value
                  ? Text(
                      '${studentController.selectedStudentIds.length} Selected',
                      style: Theme.of(context).textTheme.headlineSmall,
                    )
                  : Text(
                      'Add Students',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
              leading: studentController.isSelectionMode.value
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        studentController.toggleSelectionMode();
                      },
                    )
                  : null,
              actions: [
                if (studentController.isSelectionMode.value)
                  IconButton(
                    icon: const Icon(Icons.select_all),
                    onPressed: () {
                      studentController.toggleSelectAll();
                    },
                  )
                else
                  IconButton(
                    icon: const Icon(Iconsax.import),
                    onPressed: () {
                      _showImportStudentsDialog(context);
                    },
                  ),
              ],
            )),
      ),
      floatingActionButton: Obx(() => studentController.isSelectionMode.value
          ? FloatingActionButton(
              onPressed: () {
                if (studentController.selectedStudentIds.isNotEmpty) {
                  _showDeleteSelectedConfirmation(context);
                }
              },
              backgroundColor: Colors.red,
              child: const Icon(Iconsax.trash),
            )
          : FloatingActionButton(
              onPressed: () {
                _showAddStudentDialog(context);
              },
              backgroundColor: dark ? TColors.blue : TColors.yellow,
              child: const Icon(Iconsax.user_add),
            )),
      body: Obx(() {
        if (studentController.isLoading.value) {
          return SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              itemCount: 9,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                   baseColor: dark ? TColors.darkerGrey : Colors.grey.shade300,
                  highlightColor: dark ? TColors.yellow : TColors.primary,
                  child: Card(
                    margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(TSizes.md),
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 24,
                      ),
                      title: Container(
                        height: 16,
                        width: 100,
                        color: Colors.grey,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: TSizes.spaceBtwItems / 2),
                          Container(
                            height: 14,
                            width: 150,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      trailing: Container(
                        height: 24,
                        width: 24,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        if (studentController.students.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              //print('Refreshing student data');
              await studentController.loadStudentsForClass(classModel.id);
            },
            color: dark ? TColors.yellow : TColors.primary,
            backgroundColor: dark ? TColors.darkerGrey : Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.user_add,
                    size: 72,
                    color: dark ? TColors.yellow : TColors.primary,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Text(
                    'Start Adding Students!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: dark ? TColors.yellow : TColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  Text(
                    'Tap the button below to add students',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: dark ? TColors.light : TColors.dark,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddStudentDialog(context);
                    },
                    icon: const Icon(Iconsax.add_circle),
                    label: const Text('Manually Add Students'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dark ? TColors.yellow : TColors.primary,
                      foregroundColor: dark ? TColors.dark : TColors.light,
                      padding: const EdgeInsets.symmetric(
                          horizontal: TSizes.lg, vertical: TSizes.sm),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          itemCount: studentController.students.length,
          itemBuilder: (context, index) {
            final student = studentController.students[index];
            return Obx(() {
              final isSelected =
                  studentController.selectedStudentIds.contains(student.id);
              return Card(
                margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                  side: isSelected
                      ? BorderSide(
                          color: dark ? TColors.yellow : TColors.primary,
                          width: 2.5,
                        )
                      : BorderSide.none,
                ),
                color: isSelected
                    ? (dark
                        ? TColors.darkerGrey.withOpacity(0.7)
                        : Colors.grey.withOpacity(0.1))
                    : null,
                child: InkWell(
                  onTap: () {
                    if (studentController.isSelectionMode.value) {
                      studentController.toggleStudentSelection(student.id);
                    }
                  },
                  onLongPress: () {
                    if (!studentController.isSelectionMode.value) {
                      studentController.toggleSelectionMode();
                      studentController.toggleStudentSelection(student.id);
                    }
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(TSizes.md),
                    leading: studentController.isSelectionMode.value
                        ? Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? (dark ? TColors.yellow : TColors.primary)
                                  : Colors.transparent,
                              border: Border.all(
                                color: dark ? TColors.yellow : TColors.primary,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    size: 16,
                                    color: dark ? TColors.dark : Colors.white,
                                  )
                                : null,
                          )
                        : StudentAvatar(
                            imageUrl: student.imageUrl,
                            name: student.name,
                            size: 40,
                            isDarkMode: dark,
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
                    trailing: studentController.isSelectionMode.value
                        ? null
                        : IconButton(
                            icon: const Icon(Iconsax.trash),
                            color: Colors.red,
                            onPressed: () {
                              _showDeleteConfirmation(
                                  context, student.id, student.name);
                            },
                          ),
                  ),
                ),
              );
            });
          },
        );
      }),
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    //print('Opening add student dialog');
    final dark = THelperFunction.isDarkMode(context);

    studentController.nameController.clear();
    studentController.rollNumberController.clear();
    studentController
        .clearSelectedImage(); // Clear any previously selected image
    //print('Form controllers reset');

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
                          color: dark ? TColors.yellow : TColors.primary,
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
                                color: dark ? TColors.yellow : TColors.primary,
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
          ElevatedButton(
            onPressed: () {
              //print('Add student dialog cancelled');
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              // side: BorderSide(
              //   color: Colors.grey,
              //   width: 1,
              // ),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              //print('Attempting to add student');
              if (studentController.nameController.text.trim().isEmpty ||
                  studentController.rollNumberController.text.trim().isEmpty) {
                //print('Validation failed: Empty fields');
                Get.snackbar(
                  'Error',
                  'Please fill in all fields',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              //print('Adding student to class');
              studentController.addStudentToClass();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: dark ? TColors.yellow : TColors.primary,
              foregroundColor: dark ? TColors.dark : Colors.white,
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
                  color: dark ? TColors.yellow : TColors.primary,
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
                  color: dark ? TColors.yellow : TColors.primary,
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

  void _showImportStudentsDialog(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    final searchController = TextEditingController();
    final selectedSemester = RxInt(0);

    studentController.fetchAvailableStudents();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: Obx(() {
            if (studentController.isFetchingAvailableStudents.value) {
              return ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: dark ? TColors.darkerGrey : Colors.grey.shade300,
                  highlightColor: dark ? TColors.yellow : TColors.primary,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 24,
                      ),
                      title: Container(
                        height: 16,
                        width: 100,
                        color: Colors.grey,
                      ),
                      subtitle: Container(
                        height: 14,
                        width: 150,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              );
            }

            if (studentController.availableStudents.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.people,
                        size: 80,
                        color: dark ? TColors.yellow : TColors.primary),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    Text(
                      'No Students Available',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: dark ? TColors.yellow : TColors.primary,
                              ),
                    ),
                    const SizedBox(height: TSizes.sm),
                    Text(
                      'There are no students available to import at the moment.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    Container(
                      padding: const EdgeInsets.all(TSizes.sm),
                      decoration: BoxDecoration(
                        color: dark ? TColors.darkBackground : TColors.light,
                        borderRadius:
                            BorderRadius.circular(TSizes.cardRadiusMd),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Text(
                        'Try adding new students first using supabase',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ],
                ),
              );
            }

            final filteredStudents =
                studentController.availableStudents.where((student) {
              final searchMatch = searchController.text.isEmpty ||
                  student.name
                      .toLowerCase()
                      .contains(searchController.text.toLowerCase()) ||
                  student.rollNumber
                      .toLowerCase()
                      .contains(searchController.text.toLowerCase());
              final semesterMatch = selectedSemester.value == 0 ||
                  _getSemesterFromRollNumber(student.rollNumber) ==
                      selectedSemester.value;
              return searchMatch && semesterMatch;
            }).toList();

            return Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search by name or roll number',
                    prefixIcon: Icon(Iconsax.search_normal,
                        color: dark ? TColors.yellow : TColors.primary),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(TSizes.inputFieldRadius),
                    ),
                  ),
                  onChanged: (_) => Get.forceAppUpdate(),
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
                const SizedBox(height: TSizes.borderRadiusSm),

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
                            //print('Sorting students by: $value');
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
                Expanded(
                  child: filteredStudents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No matching students found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = filteredStudents[index];
                            final semester =
                                _getSemesterFromRollNumber(student.rollNumber);
                            final semesterText =
                                semester > 0 ? 'Semester $semester' : '';

                            return Obx(() => Card(
                                  margin: const EdgeInsets.only(
                                      bottom: TSizes.spaceBtwItems),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        TSizes.cardRadiusMd),
                                  ),
                                  child: CheckboxListTile(
                                    value: studentController.selectedStudents
                                        .any((s) => s.id == student.id),
                                    onChanged: (isSelected) {
                                      if (isSelected == true) {
                                        studentController
                                            .selectStudent(student);
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
                                                  : TColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                    secondary: CircleAvatar(
                                      backgroundColor: dark
                                          ? TColors.yellow
                                          : TColors.primary,
                                      child: Text(
                                        student.name.substring(0, 1),
                                        style: TextStyle(
                                          color: dark
                                              ? TColors.dark
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ));
                          },
                        ),
                ),
              ],
            );
          }),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              //print('Add student dialog cancelled');
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              // side: BorderSide(
              //   color: Colors.grey,
              //   width: 1,
              // ),
            ),
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
                onPressed: studentController.selectedStudents.isEmpty
                    ? null
                    : () {
                        studentController.importSelectedStudents();
                        Get.back();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: dark ? TColors.yellow : TColors.primary,
                  foregroundColor: dark ? TColors.dark : Colors.white,
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
      //print('Error parsing semester from roll number: $e');
      return 0;
    }
  }

  // New method to show delete confirmation for a single student
  void _showDeleteConfirmation(
      BuildContext context, String studentId, String studentName) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove Student'),
        content: Text(
          'Are you sure you want to remove $studentName from the class?',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              //print('Add student dialog cancelled');
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              // side: BorderSide(
              //   color: Colors.grey,
              //   width: 1,
              // ),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              //print('Confirming student deletion: $studentId');
              Get.back();
              studentController.removeStudentFromClass(
                studentId,
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
  }

  // New method to show delete confirmation for multiple students
  void _showDeleteSelectedConfirmation(BuildContext context) {
    final count = studentController.selectedStudentIds.length;

    Get.dialog(
      AlertDialog(
        title: const Text('Remove Students'),
        content: Text(
          'Are you sure you want to remove $count selected ${count == 1 ? 'student' : 'students'} from the class?',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              //print('Add student dialog cancelled');
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              // side: BorderSide(
              //   color: Colors.grey,
              //   width: 1,
              // ),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // //print('Confirming deletion of $count students');
              Get.back();
              studentController.removeSelectedStudentsFromClass();
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
  }
}
