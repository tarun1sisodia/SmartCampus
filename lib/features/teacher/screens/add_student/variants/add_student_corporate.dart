import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/student_controller.dart';
import '../../../../common/widgets/student_avatar.dart';
import '../../../../models/class_model.dart';
import '../../../../common/utils/constants/colors.dart';

class AddStudentCorporate extends StatelessWidget {
  final StudentController controller;
  final ClassModel classModel;

  const AddStudentCorporate({super.key, required this.controller, required this.classModel});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.industrialCorporate);

    return Container(
      color: const Color(0xFFF1F5F9),
      child: Obx(() {
        if (controller.isLoading.value) {
           return _buildCorporateLoading();
        }

        if (controller.students.isEmpty) {
           return _buildCorporateEmpty(context);
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadStudentsForClass(classModel.id),
          child: ListView.builder(
            controller: controller.scrollController,
            padding: const EdgeInsets.all(24),
            itemCount: controller.students.length + (controller.isLoadingMoreStudents.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.students.length) {
                return const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator()));
              }
              final student = controller.students[index];
              return _buildCorporateStudentRow(context, student);
            },
          ),
        );
      }),
    );
  }

  Widget _buildCorporateLoading() {
    return const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)));
  }

  Widget _buildCorporateEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.user_add, size: 64, color: Color(0xFF94A3B8)),
          const SizedBox(height: 24),
          const Text('ROSTER_MANIFEST_VOID', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
          const SizedBox(height: 32),
          _buildCorporateActionBtn('INITIALIZE_ENROLLMENT', Iconsax.user_add, () => _showAddDialog(context)),
        ],
      ),
    );
  }

  Widget _buildCorporateActionBtn(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(color: const Color(0xFF0F172A), border: Border.all(color: Colors.white, width: 0.5)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildCorporateStudentRow(BuildContext context, dynamic student) {
    final isSelected = controller.selectedStudentIds.contains(student.id);
    final isSelectionMode = controller.isSelectionMode.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1),
      ),
      child: ListTile(
         onTap: () => isSelectionMode ? controller.toggleStudentSelection(student.id) : null,
         onLongPress: () {
            if (!isSelectionMode) {
               controller.toggleSelectionMode();
               controller.toggleStudentSelection(student.id);
            }
         },
         contentPadding: const EdgeInsets.all(16),
         leading: isSelectionMode 
            ? _buildCorporateCheckbox(isSelected)
            : StudentAvatar(imageUrl: student.imageUrl, name: student.name, size: 48, isDarkMode: false),
         title: Text(student.name.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A))),
         subtitle: Text('ROLL_NODE: ${student.rollNumber}'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Color(0xFF94A3B8))),
         trailing: !isSelectionMode 
            ? IconButton(icon: const Icon(Iconsax.trash, size: 18, color: Colors.grey), onPressed: () => controller.removeStudentFromClass(student.id))
            : null,
      ),
    );
  }

  Widget _buildCorporateCheckbox(bool isSelected) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: isSelected ? const Color(0xFF0F172A) : Colors.transparent, border: Border.all(color: const Color(0xFF0F172A), width: 2)),
      child: isSelected ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
    );
  }

  void _showAddDialog(BuildContext context) {
    controller.nameController.clear();
    controller.rollNumberController.clear();
    controller.clearSelectedImage();

    Get.dialog(
       AlertDialog(
         shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: Color(0xFF0F172A), width: 2.5)),
         title: const Text('STUDENT_ENROLLMENT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
         content: SingleChildScrollView(
            child: Column(
               mainAxisSize: MainAxisSize.min,
               children: [
                  Obx(() => GestureDetector(
                     onTap: () => _showPickerOptions(context),
                     child: Container(
                        width: 90, height: 90,
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), border: Border.all(color: const Color(0xFF0F172A), width: 2)),
                        child: controller.selectedImage.value != null 
                           ? Image.file(controller.selectedImage.value!, fit: BoxFit.cover)
                           : const Icon(Iconsax.camera, color: Color(0xFF0F172A), size: 28),
                     ),
                  )),
                  const SizedBox(height: 24),
                  _buildCorporateInput(controller.nameController, 'FULL_NAME', Iconsax.user),
                  const SizedBox(height: 12),
                  _buildCorporateInput(controller.rollNumberController, 'ROLL_NUMBER', Iconsax.hashtag),
               ],
            ),
         ),
         actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('TERMINATE', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w900, fontSize: 10))),
            ElevatedButton(
               onPressed: () {
                  if (controller.nameController.text.trim().isNotEmpty) {
                     controller.addStudentToClass();
                     Get.back();
                  }
               },
               style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
               child: const Text('ENROLL_NODE'),
            ),
         ],
       ),
    );
  }

  Widget _buildCorporateInput(TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
       controller: ctrl,
       style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
       decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF94A3B8)),
          prefixIcon: Icon(icon, color: const Color(0xFF0F172A), size: 16),
          border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
          focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Color(0xFF0F172A), width: 2)),
       ),
    );
  }

  void _showPickerOptions(BuildContext context) {
     Get.bottomSheet(
        Container(
           padding: const EdgeInsets.all(24),
           color: Colors.white,
           child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 const Text('IMAGE_SOURCE_SELECTION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                 const SizedBox(height: 20),
                 ListTile(leading: const Icon(Iconsax.camera), title: const Text('CAMERA_CAPTURE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)), onTap: () { Get.back(); controller.pickImage(ImageSource.camera); }),
                 ListTile(leading: const Icon(Iconsax.gallery), title: const Text('STORAGE_IMPORT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)), onTap: () { Get.back(); controller.pickImage(ImageSource.gallery); }),
                 const SizedBox(height: 20),
              ],
           ),
        ),
     );
  }
}
