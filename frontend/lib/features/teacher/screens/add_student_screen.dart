import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import '../../../common/widgets/student_avatar.dart';
import '../../../models/class_model.dart';
import '../../../common/utils/constants/colors.dart';
import '../controllers/student_controller.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';

class AddStudentScreen extends StatelessWidget {
  final ClassModel classModel;
  final studentController = Get.put(StudentController());

  AddStudentScreen({super.key, required this.classModel});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      studentController.setSelectedClass(classModel);
    });

    return Scaffold(
      backgroundColor: TColors.slate50,
      appBar: AppBar(
        title: Obx(() => Text(
              (studentController.isSelectionMode.value
                      ? '${studentController.selectedStudentIds.length} SELECTED'
                      : 'ADD STUDENTS')
                  .toUpperCase(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.0),
            )),
        leading: Obx(() => studentController.isSelectionMode.value
            ? IconButton(
                icon: const Icon(Icons.close, color: Color(0xFFE11D48)),
                onPressed: () => studentController.toggleSelectionMode())
            : const BackButton()),
        actions: [
          Obx(() => studentController.isSelectionMode.value
              ? IconButton(
                  icon: const Icon(Icons.select_all, color: TColors.executiveNavy),
                  onPressed: () => studentController.toggleSelectAll())
              : IconButton(
                  icon: const Icon(Iconsax.import, color: TColors.executiveNavy),
                  onPressed: () => _showImportStudentsDialog(context))),
        ],
      ),
      floatingActionButton: Obx(() => studentController.isSelectionMode.value
          ? FloatingActionButton.extended(
              onPressed: () => studentController.selectedStudentIds.isNotEmpty
                  ? _showDeleteSelectedConfirmation(context)
                  : null,
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              icon: const Icon(Iconsax.trash, size: 20),
              label: const Text('DELETE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: const BorderSide(color: Colors.white, width: 1.5)),
            )
          : FloatingActionButton.extended(
              onPressed: () => _showAddStudentDialog(context),
              backgroundColor: TColors.executiveNavy,
              foregroundColor: Colors.white,
              icon: const Icon(Iconsax.user_add, size: 20),
              label: const Text('ADD STUDENT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: const BorderSide(color: Colors.white, width: 1.5)),
            )),
      body: Obx(() {
        if (studentController.isLoading.value) {
          return _buildLoadingState(context);
        }
        if (studentController.students.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () => studentController.loadStudentsForClass(classModel.id),
          child: ListView.builder(
            controller: studentController.scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: studentController.students.length + (studentController.isLoadingMoreStudents.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == studentController.students.length) {
                return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()));
              }
              final student = studentController.students[index];
              return _buildStudentRow(context, student);
            },
          ),
        );
      }),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: TColors.slate200,
        highlightColor: TColors.white,
        child: Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.user_add, size: 80, color: TColors.slate300),
            const SizedBox(height: 24),
            const Text('ROSTER EMPTY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: TColors.slate900)),
            const SizedBox(height: 8),
            const Text('NO STUDENTS ASSIGNED TO THIS CLASS YET.', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: TColors.slate600), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddStudentDialog(context),
              icon: const Icon(Iconsax.add_circle, size: 20),
              label: const Text('ADD STUDENT MANUALLY'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentRow(BuildContext context, dynamic student) {
    return Obx(() {
      final isSelected = studentController.selectedStudentIds.contains(student.id);

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? TColors.executiveNavy : TColors.slate300,
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (studentController.isSelectionMode.value)
                  _buildSelectionCheckbox(isSelected)
                else
                  StudentAvatar(
                    imageUrl: student.imageUrl,
                    name: student.name,
                    size: 48,
                    isDarkMode: false,
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name.toString().toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: TColors.slate900),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'ROLL: ${student.rollNumber}'.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: TColors.slate600, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
                if (!studentController.isSelectionMode.value)
                  IconButton(
                    icon: const Icon(Iconsax.trash, color: Color(0xFFE11D48), size: 20),
                    onPressed: () => _showDeleteConfirmation(context, student.id, student.name),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSelectionCheckbox(bool isSelected) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isSelected ? TColors.executiveNavy : Colors.transparent,
        border: Border.all(color: TColors.executiveNavy, width: 2.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    studentController.nameController.clear();
    studentController.rollNumberController.clear();
    studentController.clearSelectedImage();

    _showCorporateDialog(
      context,
      title: 'ADD NEW STUDENT',
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
                      color: TColors.slate50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: TColors.executiveNavy, width: 2.5),
                    ),
                    child: studentController.selectedImage.value != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Image.file(studentController.selectedImage.value!, fit: BoxFit.cover),
                          )
                        : const Icon(Iconsax.camera, size: 32, color: TColors.executiveNavy),
                  ),
                )),
            const SizedBox(height: 24),
            TextFormField(
              controller: studentController.nameController,
              decoration: const InputDecoration(labelText: 'FULL NAME', prefixIcon: Icon(Iconsax.user)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: studentController.rollNumberController,
              decoration: const InputDecoration(labelText: 'ROLL NUMBER', prefixIcon: Icon(Iconsax.hashtag)),
            ),
          ],
        ),
      ),
      confirmLabel: 'ADD STUDENT',
      onConfirm: () {
        if (studentController.nameController.text.trim().isEmpty || studentController.rollNumberController.text.trim().isEmpty) {
          TSnackBar.showError(message: 'FILL ALL REQUIRED FIELDS.');
          return;
        }
        studentController.addStudentToClass();
        Get.back();
      },
    );
  }

  void _showImagePickerOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: TColors.white,
          border: Border(top: BorderSide(color: TColors.executiveNavy, width: 3.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('PHOTO SOURCE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 16),
            _buildOptionTile(label: 'CAMERA', icon: Iconsax.camera, onTap: () { Get.back(); studentController.pickImage(ImageSource.camera); }),
            _buildOptionTile(label: 'GALLERY', icon: Iconsax.gallery, onTap: () { Get.back(); studentController.pickImage(ImageSource.gallery); }),
            if (studentController.selectedImage.value != null)
              _buildOptionTile(label: 'REMOVE PHOTO', icon: Iconsax.trash, color: const Color(0xFFE11D48), onTap: () { Get.back(); studentController.clearSelectedImage(); }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({required String label, required IconData icon, Color color = TColors.executiveNavy, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(border: Border.all(color: TColors.slate300, width: 1.5), borderRadius: BorderRadius.circular(4)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14)),
        onTap: onTap,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String studentId, String name) {
    _showCorporateDialog(
      context,
      title: 'DELETE STUDENT',
      content: Text('ARE YOU SURE YOU WANT TO REMOVE "${name.toUpperCase()}" FROM THIS CLASS?', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: TColors.slate600)),
      confirmLabel: 'DELETE',
      onConfirm: () {
        Get.back();
        studentController.removeStudentFromClass(studentId);
      },
      isDestructive: true,
    );
  }

  void _showDeleteSelectedConfirmation(BuildContext context) {
    final count = studentController.selectedStudentIds.length;
    _showCorporateDialog(
      context,
      title: 'DELETE SELECTED',
      content: Text('ARE YOU SURE YOU WANT TO DELETE $count SELECTED STUDENTS FROM THIS ROSTER?', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: TColors.slate600)),
      confirmLabel: 'DELETE',
      onConfirm: () {
        Get.back();
        studentController.removeSelectedStudentsFromClass();
      },
      isDestructive: true,
    );
  }

  void _showImportStudentsDialog(BuildContext context) {
    final searchController = TextEditingController();
    final selectedSemester = RxInt(0);
    studentController.fetchAvailableStudents();

    Get.dialog(
      AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: TColors.executiveNavy, width: 2.0)),
        title: const Text('IMPORT STUDENTS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: Obx(() {
            if (studentController.isFetchingAvailableStudents.value) return const Center(child: CircularProgressIndicator());
            if (studentController.availableStudents.isEmpty) return const Center(child: Text('NO DATA AVAILABLE'));

            final filteredStudents = studentController.availableStudents.where((student) {
              final searchMatch = searchController.text.isEmpty ||
                  student.name.toLowerCase().contains(searchController.text.toLowerCase()) ||
                  student.rollNumber.toLowerCase().contains(searchController.text.toLowerCase());
              return searchMatch;
            }).toList();

            return Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(labelText: 'SEARCH ROSTER', prefixIcon: Icon(Iconsax.search_normal)),
                  onChanged: (_) => studentController.availableStudents.refresh(),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      final isSelected = studentController.selectedStudents.any((s) => s.id == student.id);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? TColors.blue100 : Colors.transparent,
                          border: Border.all(color: TColors.slate300, width: 1.0),
                        ),
                        child: CheckboxListTile(
                          value: isSelected,
                          onChanged: (v) => v == true ? studentController.selectStudent(student) : studentController.deselectStudent(student),
                          title: Text(student.name.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                          subtitle: Text('ROLL: ${student.rollNumber}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 9)),
                          activeColor: TColors.executiveNavy,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('CANCEL', style: TextStyle(color: TColors.slate600, fontWeight: FontWeight.w900))),
          ElevatedButton(
            onPressed: () { studentController.importSelectedStudents(); Get.back(); },
            child: const Text('IMPORT'),
          ),
        ],
      ),
    );
  }

  void _showCorporateDialog(BuildContext context, {required String title, required Widget content, required String confirmLabel, required VoidCallback onConfirm, bool isDestructive = false}) {
    Get.dialog(
      AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: TColors.executiveNavy, width: 2.0)),
        backgroundColor: TColors.white,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        content: content,
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('CANCEL', style: TextStyle(color: TColors.slate600, fontWeight: FontWeight.w900))),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(backgroundColor: isDestructive ? const Color(0xFFE11D48) : TColors.executiveNavy),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
