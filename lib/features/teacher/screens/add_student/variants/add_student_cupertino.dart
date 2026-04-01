import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, InkWell, Color, CircleAvatar, FontWeight, TextStyle, BorderRadius, BoxDecoration, Border, Widget, EdgeInsets, Column, Row, Expanded, SizedBox, BuildContext, StatelessWidget, Center, ListView, Icon, MainAxisAlignment, CrossAxisAlignment, VoidCallback, FileImage, RefreshIndicator;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../../controllers/student_controller.dart';
import '../../../../../common/widgets/student_avatar.dart';
import '../../../../../models/class_model.dart';

class AddStudentCupertino extends StatelessWidget {
  final StudentController controller;
  final ClassModel classModel;

  const AddStudentCupertino({super.key, required this.controller, required this.classModel});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.cupertinoPro);

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CupertinoActivityIndicator());
        }

        if (controller.students.isEmpty) {
          return _buildIosEmpty(context);
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadStudentsForClass(classModel.id),
          child: ListView.builder(
            controller: controller.scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: controller.students.length + (controller.isLoadingMoreStudents.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.students.length) {
                return const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: CupertinoActivityIndicator()));
              }
              final student = controller.students[index];
              return _buildIosStudentRow(context, student);
            },
          ),
        );
      }),
    );
  }

  Widget _buildIosEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.person_add, size: 80, color: Color(0xFFC7C7CC)),
            const SizedBox(height: 24),
            const Text('Empty Roster', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black, letterSpacing: -0.5)),
            const SizedBox(height: 32),
            CupertinoButton.filled(
              onPressed: () => _showAddDialog(context),
              child: const Text('Add Student', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIosStudentRow(BuildContext context, dynamic student) {
    final isSelected = controller.selectedStudentIds.contains(student.id);
    final isSelectionMode = controller.isSelectionMode.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: _ListTile(
         onTap: () => isSelectionMode ? controller.toggleStudentSelection(student.id) : null,
         onLongPress: () {
            if (!isSelectionMode) {
               controller.toggleSelectionMode();
               controller.toggleStudentSelection(student.id);
            }
         },
         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
         leading: isSelectionMode 
            ? _buildIosCheckbox(isSelected)
            : StudentAvatar(imageUrl: student.imageUrl, name: student.name, size: 44, isDarkMode: false),
         title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.black, letterSpacing: -0.2)),
         subtitle: Text('ID: ${student.rollNumber}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF8E8E93))),
         trailing: !isSelectionMode 
            ? _IconButton(icon: const Icon(CupertinoIcons.trash, size: 18, color: Color(0xFFC7C7CC)), onPressed: () => controller.removeStudentFromClass(student.id))
            : null,
      ),
    );
  }

  Widget _buildIosCheckbox(bool isSelected) {
    return Container(
      width: 24, height: 24,
      decoration: BoxDecoration(color: isSelected ? const Color(0xFF007AFF) : Colors.transparent, border: Border.all(color: const Color(0xFF007AFF), width: 2), borderRadius: BorderRadius.circular(12)),
      child: isSelected ? const Icon(CupertinoIcons.checkmark, size: 16, color: Colors.white) : null,
    );
  }

  void _showAddDialog(BuildContext context) {
    controller.nameController.clear();
    controller.rollNumberController.clear();
    controller.clearSelectedImage();

    Get.dialog(
       CupertinoAlertDialog(
         title: const Text('New Student Enrollment'),
         content: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
               children: [
                  Obx(() => GestureDetector(
                     onTap: () => _showPicker(context),
                     child: CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFFF2F2F7),
                        backgroundImage: controller.selectedImage.value != null ? FileImage(controller.selectedImage.value!) : null,
                        child: controller.selectedImage.value == null ? const Icon(CupertinoIcons.camera, color: Color(0xFF007AFF), size: 24) : null,
                     ),
                  )),
                  const SizedBox(height: 24),
                  CupertinoTextField(
                     controller: controller.nameController,
                     placeholder: 'Full Name',
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(8)),
                  ),
                  const SizedBox(height: 12),
                  CupertinoTextField(
                     controller: controller.rollNumberController,
                     placeholder: 'Roll Number',
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(8)),
                  ),
               ],
            ),
         ),
         actions: [
            CupertinoDialogAction(onPressed: () => Get.back(), child: const Text('Cancel')),
            CupertinoDialogAction(
               isDefaultAction: true,
               onPressed: () {
                  if (controller.nameController.text.trim().isNotEmpty) {
                     controller.addStudentToClass();
                     Get.back();
                  }
               },
               child: const Text('Enroll'),
            ),
         ],
       ),
    );
  }

  void _showPicker(BuildContext context) {
     Get.bottomSheet(
        CupertinoActionSheet(
           title: const Text('Select Enrollment Photo'),
           actions: [
              CupertinoActionSheetAction(onPressed: () { Get.back(); controller.pickImage(ImageSource.camera); }, child: const Text('Take Photo')),
              CupertinoActionSheetAction(onPressed: () { Get.back(); controller.pickImage(ImageSource.gallery); }, child: const Text('Choose from Library')),
           ],
           cancelButton: CupertinoActionSheetAction(isDestructiveAction: true, onPressed: () => Get.back(), child: const Text('Cancel')),
        ),
     );
  }
}

class _ListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry contentPadding;

  const _ListTile({this.leading, required this.title, this.subtitle, this.trailing, this.onTap, this.onLongPress, required this.contentPadding});

  @override
  Widget build(BuildContext context) {
    return InkWell(
       onTap: onTap,
       onLongPress: onLongPress,
       child: Padding(
          padding: contentPadding,
          child: Row(
             children: [
                if (leading != null) ...[leading!, const SizedBox(width: 16)],
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [title, if (subtitle != null) subtitle!])),
                if (trailing != null) trailing!,
             ],
          ),
       ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;
  const _IconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(padding: EdgeInsets.zero, onPressed: onPressed, child: icon);
  }
}
