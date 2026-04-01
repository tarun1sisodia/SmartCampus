import 'package:smart_campus/common/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/student_controller.dart';
import '../../../../../common/widgets/student_avatar.dart';
import '../../../../models/class_model.dart';
import '../../../../../common/utils/constants/sized.dart';

class AddStudentMinimalist extends StatelessWidget {
  final StudentController controller;
  final ClassModel classModel;

  const AddStudentMinimalist({super.key, required this.controller, required this.classModel});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.softMinimalist);

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Obx(() {
        if (controller.isLoading.value) {
           return Center(child: CircularProgressIndicator(color: TColors.primary));
        }

        if (controller.students.isEmpty) {
           return _buildMinimalistEmpty(context, tokens);
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadStudentsForClass(classModel.id),
          child: ListView.builder(
            controller: controller.scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: controller.students.length + (controller.isLoadingMoreStudents.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.students.length) {
                return const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: CircularProgressIndicator()));
              }
              final student = controller.students[index];
              return _buildMinimalistStudentRow(context, student, tokens);
            },
          ),
        );
      }),
    );
  }

  Widget _buildMinimalistEmpty(BuildContext context, PatternTokens tokens) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.user_add, size: 80, color: const Color(0xFFE2E8F0)),
            const SizedBox(height: 24),
            const Text('Roster feels empty', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF1E293B))),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddDialog(context, tokens),
              icon: const Icon(Iconsax.add, size: 18),
              label: const Text('Add Student Manually'),
              style: ElevatedButton.styleFrom(backgroundColor: TColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalistStudentRow(BuildContext context, dynamic student, PatternTokens tokens) {
    final isSelected = controller.selectedStudentIds.contains(student.id);
    final isSelectionMode = controller.isSelectionMode.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: isSelected ? TColors.primary : Colors.transparent, width: 2),
      ),
      child: ListTile(
         onTap: () => isSelectionMode ? controller.toggleStudentSelection(student.id) : null,
         onLongPress: () {
            if (!isSelectionMode) {
               controller.toggleSelectionMode();
               controller.toggleStudentSelection(student.id);
            }
         },
         contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
         leading: isSelectionMode 
            ? _buildMinimalistCheckbox(isSelected, tokens)
            : StudentAvatar(imageUrl: student.imageUrl, name: student.name, size: 48, isDarkMode: false),
         title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B))),
         subtitle: Text('Roll: ${student.rollNumber}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: Color(0xFF94A3B8))),
         trailing: !isSelectionMode 
            ? IconButton(icon: const Icon(Iconsax.trash, size: 18, color: Color(0xFFCBD5E1)), onPressed: () => controller.removeStudentFromClass(student.id))
            : null,
      ),
    );
  }

  Widget _buildMinimalistCheckbox(bool isSelected, PatternTokens tokens) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: isSelected ? TColors.primary : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
      child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
    );
  }

  void _showAddDialog(BuildContext context, PatternTokens tokens) {
    controller.nameController.clear();
    controller.rollNumberController.clear();
    controller.clearSelectedImage();

    Get.dialog(
       AlertDialog(
         backgroundColor: Colors.white,
         surfaceTintColor: Colors.transparent,
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
         title: const Text('Add new student', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1E293B))),
         content: SingleChildScrollView(
            child: Column(
               mainAxisSize: MainAxisSize.min,
               children: [
                  Obx(() => GestureDetector(
                     onTap: () => _showPickerOptions(context, tokens),
                     child: CircleAvatar(
                        radius: 44,
                        backgroundColor: const Color(0xFFF1F5F9),
                        backgroundImage: controller.selectedImage.value != null ? FileImage(controller.selectedImage.value!) : null,
                        child: controller.selectedImage.value == null ? Icon(Iconsax.camera, color: TColors.primary, size: 28) : null,
                     ),
                  )),
                  const SizedBox(height: 24),
                  _buildMinimalistInput(controller.nameController, 'Student Full Name', Iconsax.user),
                  const SizedBox(height: 16),
                  _buildMinimalistInput(controller.rollNumberController, 'Roll Number', Iconsax.hashtag),
               ],
            ),
         ),
         actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Discard', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700, fontSize: 12))),
            ElevatedButton(
               onPressed: () {
                  if (controller.nameController.text.trim().isNotEmpty) {
                     controller.addStudentToClass();
                     Get.back();
                  }
               },
               style: ElevatedButton.styleFrom(backgroundColor: TColors.primary, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
               child: const Text('Add to Roster'),
            ),
         ],
       ),
    );
  }

  Widget _buildMinimalistInput(TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
       controller: ctrl,
       style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
       decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF94A3B8)),
          prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 16),
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
       ),
    );
  }

  void _showPickerOptions(BuildContext context, PatternTokens tokens) {
     Get.bottomSheet(
        Container(
           padding: const EdgeInsets.all(32),
           decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
           child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 const Text('Select Photo Source', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                 const SizedBox(height: 24),
                 _buildPickerTile('Use Camera', Iconsax.camera, () { Get.back(); controller.pickImage(ImageSource.camera); }),
                 const SizedBox(height: 12),
                 _buildPickerTile('Browse Gallery', Iconsax.gallery, () { Get.back(); controller.pickImage(ImageSource.gallery); }),
                 const SizedBox(height: 16),
              ],
           ),
        ),
     );
  }

  Widget _buildPickerTile(String label, IconData icon, VoidCallback onTap) {
     return InkWell(
        onTap: onTap,
        child: Container(
           padding: const EdgeInsets.all(20),
           decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
           child: Row(
              children: [
                 Icon(icon, color: const Color(0xFF1E293B), size: 20),
                 const SizedBox(width: 16),
                 Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B))),
              ],
           ),
        ),
     );
  }
}
