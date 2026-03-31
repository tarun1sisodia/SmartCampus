import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/student_controller.dart';
import '../../../../common/widgets/student_avatar.dart';
import '../../../../models/class_model.dart';

class AddStudentAcademic extends StatelessWidget {
  final StudentController controller;
  final ClassModel classModel;

  const AddStudentAcademic({super.key, required this.controller, required this.classModel});

  @override
  Widget build(BuildContext context) {
    const paperColor = Color(0xFFFAF7F0);
    const inkColor = Color(0xFF2D2E32);
    const accentColor = Color(0xFF8B4513); // Saddle Brown
    final tokens = PatternTokens.get(UIStyle.academicClassic);

    return Container(
      color: paperColor,
      child: Obx(() {
        if (controller.isLoading.value) {
           return const Center(child: CircularProgressIndicator(color: accentColor));
        }

        if (controller.students.isEmpty) {
           return _buildScholarEmpty(context, accentColor, inkColor);
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadStudentsForClass(classModel.id),
          child: ListView.builder(
            controller: controller.scrollController,
            padding: const EdgeInsets.all(28),
            itemCount: controller.students.length + (controller.isLoadingMoreStudents.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.students.length) {
                return const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: CircularProgressIndicator()));
              }
              final student = controller.students[index];
              return _buildScholarStudentCard(context, student, accentColor, inkColor);
            },
          ),
        );
      }),
    );
  }

  Widget _buildScholarEmpty(BuildContext context, Color accent, Color ink) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.user_add, size: 80, color: ink.withOpacity(0.1)),
            const SizedBox(height: 24),
            Text('No Scholar Records Found', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: ink, fontFamily: 'Serif')),
            const SizedBox(height: 32),
            ElevatedButton.icon(
               onPressed: () => _showAddDialog(context, accent, ink),
               icon: const Icon(Iconsax.add, size: 20),
               label: const Text('New Enrollment'),
               style: ElevatedButton.styleFrom(backgroundColor: ink, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScholarStudentCard(BuildContext context, dynamic student, Color accent, Color ink) {
    final isSelected = controller.selectedStudentIds.contains(student.id);
    final isSelectionMode = controller.isSelectionMode.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: accent.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: accent.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
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
            ? _buildScholarCheckbox(isSelected, accent)
            : StudentAvatar(imageUrl: student.imageUrl, name: student.name, size: 48, isDarkMode: false),
         title: Text(student.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: ink, fontFamily: 'Serif')),
         subtitle: Text('Roll No: ${student.rollNumber}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: ink.withOpacity(0.4), fontFamily: 'Serif')),
         trailing: !isSelectionMode 
            ? IconButton(icon: Icon(Iconsax.trash, size: 18, color: ink.withOpacity(0.2)), onPressed: () => controller.removeStudentFromClass(student.id))
            : null,
      ),
    );
  }

  Widget _buildScholarCheckbox(bool isSelected, Color accent) {
    return Container(
      width: 24, height: 24,
      decoration: BoxDecoration(color: isSelected ? accent : Colors.transparent, border: Border.all(color: accent, width: 2), borderRadius: BorderRadius.circular(4)),
      child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
    );
  }

  void _showAddDialog(BuildContext context, Color accent, Color ink) {
     controller.nameController.clear();
     controller.rollNumberController.clear();
     controller.clearSelectedImage();

     Get.dialog(
        AlertDialog(
           backgroundColor: Colors.white,
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, border: Border.all(color: accent, width: 2)),
           title: Text('Scholarly Enrollment', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: ink, fontFamily: 'Serif')),
           content: SingleChildScrollView(
              child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                    Obx(() => GestureDetector(
                       onTap: () => _showPicker(context, accent, ink),
                       child: Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(color: const Color(0xFFFAF7F0), border: Border.all(color: accent.withOpacity(0.3))),
                          child: controller.selectedImage.value != null 
                             ? Image.file(controller.selectedImage.value!, fit: BoxFit.cover)
                             : Icon(Iconsax.camera, color: accent.withOpacity(0.5), size: 28),
                       ),
                    )),
                    const SizedBox(height: 32),
                    _buildScholarInput(controller.nameController, 'Full Scholar Name', Iconsax.user, accent),
                    const SizedBox(height: 16),
                    _buildScholarInput(controller.rollNumberController, 'Assigned Roll Number', Iconsax.hashtag, accent),
                 ],
              ),
           ),
           actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('Discard', style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w700, fontSize: 11, fontFamily: 'Serif'))),
              ElevatedButton(
                 onPressed: () {
                    if (controller.nameController.text.trim().isNotEmpty) {
                       controller.addStudentToClass();
                       Get.back();
                    }
                 },
                 style: ElevatedButton.styleFrom(backgroundColor: ink, foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                 child: const Text('Finalize Enrollment'),
              ),
           ],
        ),
     );
  }

  Widget _buildScholarInput(TextEditingController ctrl, String label, IconData icon, Color accent) {
     return TextFormField(
        controller: ctrl,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'Serif'),
        decoration: InputDecoration(
           labelText: label,
           labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: Colors.black38, fontFamily: 'Serif'),
           prefixIcon: Icon(icon, color: accent.withOpacity(0.4), size: 18),
           border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
           focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accent, width: 2)),
        ),
     );
  }

  void _showPicker(BuildContext context, Color accent, Color ink) {
     Get.bottomSheet(
        Container(
           padding: const EdgeInsets.all(32),
           decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFF8B4513), width: 3))),
           child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 const Text('Select Roster Image Source', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, fontFamily: 'Serif')),
                 const SizedBox(height: 24),
                 _buildPickerTile('Optical Camera', Iconsax.camera, accent, () { Get.back(); controller.pickImage(ImageSource.camera); }),
                 const SizedBox(height: 12),
                 _buildPickerTile('Academic Storage', Iconsax.gallery, accent, () { Get.back(); controller.pickImage(ImageSource.gallery); }),
                 const SizedBox(height: 16),
              ],
           ),
        ),
     );
  }

  Widget _buildPickerTile(String label, IconData icon, Color accent, VoidCallback onTap) {
     return InkWell(
        onTap: onTap,
        child: Container(
           padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(border: Border.all(color: accent.withOpacity(0.1)), color: const Color(0xFFFAF7F0)),
           child: Row(children: [Icon(icon, size: 20, color: accent), const SizedBox(width: 16), Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, fontFamily: 'Serif'))]),
        ),
     );
  }
}
