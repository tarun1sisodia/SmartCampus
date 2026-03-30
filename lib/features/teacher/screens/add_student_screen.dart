import 'package:smart_campus/common/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import '../../../common/widgets/student_avatar.dart';
import '../../../models/class_model.dart';
import '../../../common/utils/constants/sized.dart';
import '../controllers/student_controller.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';

class AddStudentScreen extends StatelessWidget {
  final ClassModel classModel;
  final studentController = Get.put(StudentController());

  AddStudentScreen({super.key, required this.classModel});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      studentController.setSelectedClass(classModel);
    });

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              studentController.isSelectionMode.value
                  ? '${studentController.selectedStudentIds.length} Selected'
                  : 'Add Students',
              style: Theme.of(context).textTheme.headlineSmall,
            )),
        leading: Obx(() => studentController.isSelectionMode.value
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => studentController.toggleSelectionMode())
            : const BackButton()),
        actions: [
          Obx(() => studentController.isSelectionMode.value
              ? IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: () => studentController.toggleSelectAll())
              : IconButton(
                  icon: const Icon(Iconsax.import),
                  onPressed: () => _showImportStudentsDialog(context))),
        ],
      ),
      floatingActionButton: Obx(() => studentController.isSelectionMode.value
          ? FloatingActionButton(
              onPressed: () => studentController.selectedStudentIds.isNotEmpty
                  ? _showDeleteSelectedConfirmation(context)
                  : null,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              child: const Icon(Iconsax.trash),
            )
          : FloatingActionButton(
              onPressed: () => _showAddStudentDialog(context),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              child: const Icon(Iconsax.user_add),
            )),
      body: Obx(() {
        if (studentController.isLoading.value)
          return _buildLoadingState(context);
        if (studentController.students.isEmpty)
          return _buildEmptyState(context);

        return RefreshIndicator(
          onRefresh: () =>
              studentController.loadStudentsForClass(classModel.id),
          child: ListView.builder(
            controller: studentController.scrollController,
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            itemCount: studentController.students.length +
                (studentController.isLoadingMoreStudents.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == studentController.students.length) {
                return const Padding(
                    padding: EdgeInsets.symmetric(vertical: TSizes.md),
                    child: Center(child: CircularProgressIndicator()));
              }
              final student = studentController.students[index];
              return _buildStudentCard(context, student);
            },
          ),
        );
      }),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      itemCount: 8,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        highlightColor: Theme.of(context).colorScheme.surface,
        child: Card(
          margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
          child: Container(
              height: 80,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusMd))),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.user_add,
              size: 72,
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text('No Students Found',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: TSizes.sm),
          const Text('Tap the button to add students to this class.',
              textAlign: TextAlign.center),
          const SizedBox(height: TSizes.lg),
          ElevatedButton.icon(
            onPressed: () => _showAddStudentDialog(context),
            icon: const Icon(Iconsax.add_circle),
            label: const Text('Add Student Manually'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, dynamic student) {
    return Obx(() {
      final isSelected =
          studentController.selectedStudentIds.contains(student.id);
      final colorScheme = Theme.of(context).colorScheme;

      return Card(
        margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems / 2),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          side: BorderSide(
            color:
                isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        color: isSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.1)
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
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: TSizes.md, vertical: TSizes.xs),
            leading: studentController.isSelectionMode.value
                ? _buildSelectionIcon(context, isSelected)
                : StudentAvatar(
                    imageUrl: student.imageUrl,
                    name: student.name,
                    size: 44,
                    isDarkMode:
                        Theme.of(context).brightness == Brightness.dark),
            title: Text(student.name,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text('Roll: ${student.rollNumber}',
                style: Theme.of(context).textTheme.labelSmall),
            trailing: studentController.isSelectionMode.value
                ? null
                : IconButton(
                    icon:
                        const Icon(Iconsax.trash, color: Colors.red, size: 20),
                    onPressed: () => _showDeleteConfirmation(
                        context, student.id, student.name),
                  ),
          ),
        ),
      );
    });
  }

  Widget _buildSelectionIcon(BuildContext context, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? colorScheme.primary : Colors.transparent,
        border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: 2),
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    studentController.nameController.clear();
    studentController.rollNumberController.clear();
    studentController.clearSelectedImage();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Student'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => GestureDetector(
                    onTap: () => _showImagePickerOptions(context),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2),
                      ),
                      child: ClipOval(
                        child: studentController.selectedImage.value != null
                            ? Image.file(studentController.selectedImage.value!,
                                fit: BoxFit.cover)
                            : Icon(Iconsax.camera,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  )),
              const SizedBox(height: TSizes.lg),
              TextField(
                controller: studentController.nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),
              TextField(
                controller: studentController.rollNumberController,
                decoration: const InputDecoration(labelText: 'Roll Number'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text(TTexts.cancel,
                  style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (studentController.nameController.text.trim().isEmpty ||
                  studentController.rollNumberController.text.trim().isEmpty) {
                TSnackBar.showError(message: 'Please fill in all fields');
                return;
              }
              studentController.addStudentToClass();
              Get.back();
            },
            child: const Text('Add Student'),
          ),
        ],
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(TSizes.cardRadiusLg))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add Photo', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: TSizes.md),
            ListTile(
              leading: const Icon(Iconsax.camera),
              title: const Text('Take a Photo'),
              onTap: () {
                Get.back();
                studentController.pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.gallery),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                studentController.pickImage(ImageSource.gallery);
              },
            ),
            if (studentController.selectedImage.value != null)
              ListTile(
                leading: const Icon(Iconsax.trash, color: Colors.red),
                title: const Text('Remove Photo',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Get.back();
                  studentController.clearSelectedImage();
                },
              ),
            const SizedBox(height: TSizes.md),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, String studentId, String name) {
    Get.defaultDialog(
      title: 'Delete Student',
      middleText: 'Are you sure you want to remove "$name" from this class?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        studentController.removeStudentFromClass(studentId);
      },
    );
  }

  void _showDeleteSelectedConfirmation(BuildContext context) {
    final count = studentController.selectedStudentIds.length;
    Get.defaultDialog(
      title: 'Delete Selected',
      middleText: 'Are you sure you want to delete $count selected students?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        studentController.removeSelectedStudentsFromClass();
      },
    );
  }

  void _showImportStudentsDialog(BuildContext context) {
    final searchController = TextEditingController();
    final selectedSemester = RxInt(0);

    studentController.fetchAvailableStudents();

    Get.dialog(
      AlertDialog(
        title: const Text('Import Students'),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: Obx(() {
            if (studentController.isFetchingAvailableStudents.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (studentController.availableStudents.isEmpty) {
              return _buildImportEmptyState(context);
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
                  decoration: const InputDecoration(
                      labelText: 'Search students...',
                      prefixIcon: Icon(Iconsax.search_normal)),
                  onChanged: (_) =>
                      studentController.availableStudents.refresh(),
                ),
                const SizedBox(height: TSizes.md),
                _buildImportFilters(context, selectedSemester),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      return Obx(() => CheckboxListTile(
                            value: studentController.selectedStudents
                                .any((s) => s.id == student.id),
                            onChanged: (v) => v == true
                                ? studentController.selectStudent(student)
                                : studentController.deselectStudent(student),
                            title: Text(student.name),
                            subtitle: Text('Roll: ${student.rollNumber}'),
                          ));
                    },
                  ),
                ),
              ],
            );
          }),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              studentController.importSelectedStudents();
              Get.back();
            },
            child: const Text('Import Selected'),
          ),
        ],
      ),
    );
  }

  Widget _buildImportFilters(BuildContext context, RxInt selectedSemester) {
    return Row(
      children: [
        Expanded(
          child: Obx(() => DropdownButton<int>(
                isExpanded: true,
                value: selectedSemester.value,
                onChanged: (v) => selectedSemester.value = v ?? 0,
                items: [
                  const DropdownMenuItem(
                      value: 0, child: Text('All Semesters')),
                  for (int i = 1; i <= 6; i++)
                    DropdownMenuItem(value: i, child: Text('Semester $i')),
                ],
              )),
        ),
        const SizedBox(width: TSizes.md),
        Expanded(
          child: Obx(() => DropdownButton<String>(
                isExpanded: true,
                value: studentController.sortOption.value,
                onChanged: (v) => v != null
                    ? studentController.sortAvailableStudents(v)
                    : null,
                items: const [
                  DropdownMenuItem(value: 'name', child: Text('Name (A-Z)')),
                  DropdownMenuItem(value: 'rollNumber', child: Text('Roll No')),
                ],
              )),
        ),
      ],
    );
  }

  Widget _buildImportEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.people,
              size: 64,
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
          const SizedBox(height: TSizes.md),
          const Text('No students available to import.',
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  int _getSemesterFromRollNumber(String rollNumber) {
    try {
      if (rollNumber.length >= 7) {
        return int.parse(rollNumber.substring(4, 5));
      }
    } catch (e) {}
    return 0;
  }
}
