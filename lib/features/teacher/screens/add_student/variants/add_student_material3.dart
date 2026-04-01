import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/student_controller.dart';
import '../../../../../common/widgets/student_avatar.dart';
import '../../../../models/class_model.dart';

class AddStudentMaterial3 extends StatelessWidget {
  final StudentController controller;
  final ClassModel classModel;

  const AddStudentMaterial3({super.key, required this.controller, required this.classModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = PatternTokens.get(UIStyle.material3);

    return Container(
      color: theme.colorScheme.surface,
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
        }

        if (controller.students.isEmpty) {
          return _buildM3Empty(theme, context);
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadStudentsForClass(classModel.id),
          child: ListView.builder(
            controller: controller.scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: controller.students.length + (controller.isLoadingMoreStudents.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.students.length) {
                return const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: CircularProgressIndicator()));
              }
              final student = controller.students[index];
              return _buildM3StudentRow(theme, context, student);
            },
          ),
        );
      }),
    );
  }

  Widget _buildM3Empty(ThemeData theme, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.user_add, size: 84, color: theme.colorScheme.primaryContainer),
            const SizedBox(height: 24),
            Text('No students enrolled', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showAddDialog(theme, context),
              icon: const Icon(Iconsax.add, size: 18),
              label: const Text('Add student manually'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildM3StudentRow(ThemeData theme, BuildContext context, dynamic student) {
    final isSelected = controller.selectedStudentIds.contains(student.id);
    final isSelectionMode = controller.isSelectionMode.value;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
         onTap: () => isSelectionMode ? controller.toggleStudentSelection(student.id) : null,
         onLongPress: () {
            if (!isSelectionMode) {
               controller.toggleSelectionMode();
               controller.toggleStudentSelection(student.id);
            }
         },
         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
         leading: isSelectionMode 
            ? _buildM3Checkbox(theme, isSelected)
            : StudentAvatar(imageUrl: student.imageUrl, name: student.name, size: 48, isDarkMode: false),
         title: Text(student.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
         subtitle: Text('Roll: ${student.rollNumber}', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
         trailing: !isSelectionMode 
            ? IconButton(icon: const Icon(Iconsax.trash, size: 18), onPressed: () => controller.removeStudentFromClass(student.id))
            : null,
      ),
    );
  }

  Widget _buildM3Checkbox(ThemeData theme, bool isSelected) {
    return Checkbox(
      value: isSelected,
      onChanged: (v) {},
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
  }

  void _showAddDialog(ThemeData theme, BuildContext context) {
    controller.nameController.clear();
    controller.rollNumberController.clear();
    controller.clearSelectedImage();

    Get.dialog(
       AlertDialog(
         backgroundColor: theme.colorScheme.surface,
         surfaceTintColor: Colors.transparent,
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
         title: Text('Enroll new student', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
         content: SingleChildScrollView(
            child: Column(
               mainAxisSize: MainAxisSize.min,
               children: [
                  Obx(() => GestureDetector(
                     onTap: () => _showPicker(theme, context),
                     child: CircleAvatar(
                        radius: 44,
                        backgroundColor: theme.colorScheme.surfaceContainerHigh,
                        backgroundImage: controller.selectedImage.value != null ? FileImage(controller.selectedImage.value!) : null,
                        child: controller.selectedImage.value == null ? Icon(Iconsax.camera, color: theme.colorScheme.primary, size: 28) : null,
                     ),
                  )),
                  const SizedBox(height: 24),
                  _buildM3Input(theme, controller.nameController, 'Full Name', Iconsax.user),
                  const SizedBox(height: 12),
                  _buildM3Input(theme, controller.rollNumberController, 'Roll Number', Iconsax.hashtag),
               ],
            ),
         ),
         actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            FilledButton(
               onPressed: () {
                  if (controller.nameController.text.trim().isNotEmpty) {
                     controller.addStudentToClass();
                     Get.back();
                  }
               },
               child: const Text('Add to Roster'),
            ),
         ],
       ),
    );
  }

  Widget _buildM3Input(ThemeData theme, TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
       controller: ctrl,
       style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
       decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.colorScheme.primary, width: 2)),
       ),
    );
  }

  void _showPicker(ThemeData theme, BuildContext context) {
     Get.bottomSheet(
        Container(
           padding: const EdgeInsets.all(24),
           decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
           child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 Text('Select Photo Source', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                 const SizedBox(height: 24),
                 _buildPickerItem(theme, 'Use Camera', Iconsax.camera, () { Get.back(); controller.pickImage(ImageSource.camera); }),
                 const SizedBox(height: 12),
                 _buildPickerItem(theme, 'Browse Gallery', Iconsax.gallery, () { Get.back(); controller.pickImage(ImageSource.gallery); }),
                 const SizedBox(height: 16),
              ],
           ),
        ),
     );
  }

  Widget _buildPickerItem(ThemeData theme, String label, IconData icon, VoidCallback onTap) {
     return InkWell(
        onTap: onTap,
        child: Container(
           padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
           child: Row(children: [Icon(icon, color: theme.colorScheme.primary), const SizedBox(width: 16), Text(label, style: const TextStyle(fontWeight: FontWeight.w700))]),
        ),
     );
  }
}
