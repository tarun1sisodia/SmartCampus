import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/student_controller.dart';
import '../../../../common/widgets/student_avatar.dart';
import '../../../../models/class_model.dart';

class AddStudentNeumorphism extends StatelessWidget {
  final StudentController controller;
  final ClassModel classModel;

  const AddStudentNeumorphism({super.key, required this.controller, required this.classModel});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFE2E8F0);
    final tokens = PatternTokens.get(UIStyle.neumorphism);

    return Container(
      color: bgColor,
      child: Obx(() {
        if (controller.isLoading.value) {
           return const Center(child: CircularProgressIndicator(color: Color(0xFF94A3B8)));
        }

        if (controller.students.isEmpty) {
           return _buildNeumorphicEmpty(context, bgColor);
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadStudentsForClass(classModel.id),
          child: ListView.builder(
            controller: controller.scrollController,
            padding: const EdgeInsets.all(24),
            itemCount: controller.students.length + (controller.isLoadingMoreStudents.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.students.length) {
                return const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: CircularProgressIndicator()));
              }
              final student = controller.students[index];
              return _buildNeumorphicStudentRow(context, student, bgColor);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNeumorphicEmpty(BuildContext context, Color bgColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.user_add, size: 80, color: const Color(0xFF94A3B8).withOpacity(0.5)),
          const SizedBox(height: 24),
          const Text('MANIFEST_VACANCY', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E293B), fontSize: 16)),
          const SizedBox(height: 32),
          _buildSoftActionBtn('INITIALIZE', Iconsax.user_add, bgColor, () => _showAddDialog(context, bgColor)),
        ],
      ),
    );
  }

  Widget _buildSoftActionBtn(String label, IconData icon, Color bgColor, VoidCallback onTap) {
    return InkWell(
       onTap: onTap,
       child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
             color: bgColor,
             borderRadius: BorderRadius.circular(16),
             boxShadow: [
                const BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 10),
                BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.5), offset: const Offset(6, 6), blurRadius: 10),
             ],
          ),
          child: Row(
             mainAxisSize: MainAxisSize.min,
             children: [
                Icon(icon, color: const Color(0xFF1E293B), size: 18),
                const SizedBox(width: 12),
                Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF1E293B))),
             ],
          ),
       ),
    );
  }

  Widget _buildNeumorphicStudentRow(BuildContext context, dynamic student, Color bgColor) {
     final isSelected = controller.selectedStudentIds.contains(student.id);
     final isSelectionMode = controller.isSelectionMode.value;

     return Container(
       margin: const EdgeInsets.only(bottom: 20),
       decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
             if (!isSelected) ...[
                const BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 12),
                BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.4), offset: const Offset(8, 8), blurRadius: 12),
             ] else ...[
                const BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8, inset: true),
                BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.5), offset: const Offset(4, 4), blurRadius: 8, inset: true),
             ]
          ],
       ),
       child: ListTile(
          onTap: () => isSelectionMode ? controller.toggleStudentSelection(student.id) : null,
          onLongPress: () {
             if (!isSelectionMode) {
                controller.toggleSelectionMode();
                controller.toggleStudentSelection(student.id);
             }
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          leading: isSelectionMode 
             ? _buildSoftCheckbox(isSelected, bgColor)
             : StudentAvatar(imageUrl: student.imageUrl, name: student.name, size: 48, isDarkMode: false),
          title: Text(student.name.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF1E293B))),
          subtitle: Text('ID_NODE: ${student.rollNumber}'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Color(0xFF64748B))),
          trailing: !isSelectionMode 
             ? IconButton(icon: const Icon(Iconsax.trash, size: 18, color: Color(0xFF94A3B8)), onPressed: () => controller.removeStudentFromClass(student.id))
             : null,
       ),
     );
  }

  Widget _buildSoftCheckbox(bool isSelected, Color bgColor) {
     return Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
           color: bgColor, borderRadius: BorderRadius.circular(8),
           boxShadow: [
              if (isSelected) ...[
                 const BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 4, inset: true),
                 BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.5), offset: const Offset(2, 2), blurRadius: 4, inset: true),
              ] else ...[
                 const BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 4),
                 BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.5), offset: const Offset(2, 2), blurRadius: 4),
              ]
           ],
        ),
        child: isSelected ? const Icon(Icons.check, size: 16, color: Color(0xFF1E293B)) : null,
     );
  }

  void _showAddDialog(BuildContext context, Color bgColor) {
     controller.nameController.clear();
     controller.rollNumberController.clear();
     controller.clearSelectedImage();

     Get.dialog(
        AlertDialog(
           backgroundColor: bgColor,
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
           title: const Text('ENROLL_NEW_OBJECT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B))),
           content: SingleChildScrollView(
              child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                    Obx(() => GestureDetector(
                       onTap: () => _showPicker(context, bgColor),
                       child: Container(
                          width: 90, height: 90,
                          decoration: BoxDecoration(
                             color: bgColor, borderRadius: BorderRadius.circular(24),
                             boxShadow: [
                                const BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
                                BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.5), offset: const Offset(4, 4), blurRadius: 8),
                             ],
                          ),
                          child: controller.selectedImage.value != null 
                             ? ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.file(controller.selectedImage.value!, fit: BoxFit.cover))
                             : const Icon(Iconsax.camera, color: Color(0xFF1E293B), size: 28),
                       ),
                    )),
                    const SizedBox(height: 28),
                    _buildSoftInput(controller.nameController, 'IDENTIFIER_NAME', Iconsax.user, bgColor),
                    const SizedBox(height: 16),
                    _buildSoftInput(controller.rollNumberController, 'DATA_NODE_ROLL', Iconsax.hashtag, bgColor),
                 ],
              ),
           ),
           actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('ABORT', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w900, fontSize: 10))),
              _buildSoftActionBtn('COMMIT', Iconsax.add, bgColor, () {
                 if (controller.nameController.text.trim().isNotEmpty) {
                    controller.addStudentToClass();
                    Get.back();
                 }
              }),
           ],
        ),
     );
  }

  Widget _buildSoftInput(TextEditingController ctrl, String label, IconData icon, Color bgColor) {
     return Container(
        decoration: BoxDecoration(
           color: bgColor, borderRadius: BorderRadius.circular(16),
           boxShadow: [
              const BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8, inset: true),
              BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.5), offset: const Offset(4, 4), blurRadius: 8, inset: true),
           ],
        ),
        child: TextFormField(
           controller: ctrl,
           style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
           decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF94A3B8)),
              prefixIcon: Icon(icon, color: const Color(0xFF1E293B), size: 16),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
           ),
        ),
     );
  }

  void _showPicker(BuildContext context, Color bgColor) {
     Get.bottomSheet(
        Container(
           padding: const EdgeInsets.all(32),
           decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
           child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 const Text('IMAGE_SOURCE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                 const SizedBox(height: 24),
                 _buildPickerTile('CAMERA_UNIT', Iconsax.camera, bgColor, () { Get.back(); controller.pickImage(ImageSource.camera); }),
                 const SizedBox(height: 12),
                 _buildPickerTile('STORAGE_IMPORT', Iconsax.gallery, bgColor, () { Get.back(); controller.pickImage(ImageSource.gallery); }),
                 const SizedBox(height: 16),
              ],
           ),
        ),
     );
  }

  Widget _buildPickerTile(String label, IconData icon, Color bgColor, VoidCallback onTap) {
     return InkWell(
        onTap: onTap,
        child: Container(
           padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(
              color: bgColor, borderRadius: BorderRadius.circular(16),
              boxShadow: [
                 const BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 6),
                 BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.4), offset: const Offset(3, 3), blurRadius: 6),
              ],
           ),
           child: Row(children: [Icon(icon, size: 20), const SizedBox(width: 16), Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))]),
        ),
     );
  }
}
