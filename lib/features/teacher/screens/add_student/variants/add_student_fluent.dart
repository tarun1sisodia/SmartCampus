import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/student_controller.dart';
import '../../../../../common/widgets/student_avatar.dart';
import '../../../../../models/class_model.dart';

class AddStudentFluent extends StatelessWidget {
  final StudentController controller;
  final ClassModel classModel;

  const AddStudentFluent({super.key, required this.controller, required this.classModel});

  @override
  Widget build(BuildContext context) {
    const fluentBg = Color(0xFFF3F3F3);

    return Container(
      color: fluentBg,
      child: Obx(() {
        if (controller.isLoading.value) {
           return const Center(child: CircularProgressIndicator(color: Color(0xFF0078D4)));
        }

        if (controller.students.isEmpty) {
           return _buildFluentEmpty(context);
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
              return _buildFluentStudentCard(context, student);
            },
          ),
        );
      }),
    );
  }

  Widget _buildFluentEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.user_add, size: 80, color: Color(0xFFC8C6C4)),
            const SizedBox(height: 24),
            const Text('No records stream found', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF201F1E))),
            const SizedBox(height: 32),
            _buildFluentActionBtn('Enroll New Node', Iconsax.add, () => _showAddDialog(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildFluentActionBtn(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
       onTap: onTap,
       child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(color: const Color(0xFF0078D4), borderRadius: BorderRadius.circular(4)),
          child: Row(
             mainAxisSize: MainAxisSize.min,
             children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 12),
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
             ],
          ),
       ),
    );
  }

  Widget _buildFluentStudentCard(BuildContext context, dynamic student) {
    final isSelected = controller.selectedStudentIds.contains(student.id);
    final isSelectionMode = controller.isSelectionMode.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isSelected ? const Color(0xFF0078D4) : Colors.black.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
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
            ? _buildFluentCheckbox(isSelected)
            : StudentAvatar(imageUrl: student.imageUrl, name: student.name, size: 44, isDarkMode: false),
         title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF201F1E))),
         subtitle: Text('ID: ${student.rollNumber}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.black.withValues(alpha: 0.4))),
         trailing: !isSelectionMode 
            ? IconButton(icon: const Icon(Iconsax.trash, size: 18, color: Color(0xFFA19F9D)), onPressed: () => controller.removeStudentFromClass(student.id))
            : null,
      ),
    );
  }

  Widget _buildFluentCheckbox(bool isSelected) {
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(color: isSelected ? const Color(0xFF0078D4) : Colors.transparent, border: Border.all(color: const Color(0xFF0078D4), width: 1.5), borderRadius: BorderRadius.circular(2)),
      child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
    );
  }

  void _showAddDialog(BuildContext context) {
     controller.nameController.clear();
     controller.rollNumberController.clear();
     controller.clearSelectedImage();

     Get.dialog(
        AlertDialog(
           backgroundColor: Colors.white,
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
           title: const Text('Enroll new scholar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF201F1E))),
           content: SingleChildScrollView(
              child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                    Obx(() => GestureDetector(
                       onTap: () => _showPicker(context),
                       child: Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(color: const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(40), border: Border.all(color: Colors.black.withValues(alpha: 0.1))),
                          child: controller.selectedImage.value != null 
                             ? ClipRRect(borderRadius: BorderRadius.circular(40), child: Image.file(controller.selectedImage.value!, fit: BoxFit.cover))
                             : const Icon(Iconsax.camera, color: Color(0xFF0078D4), size: 24),
                       ),
                    )),
                    const SizedBox(height: 24),
                    _buildFluentInput(controller.nameController, 'Full Scholar Name', Iconsax.user),
                    const SizedBox(height: 12),
                    _buildFluentInput(controller.rollNumberController, 'Roll Number', Iconsax.hashtag),
                 ],
              ),
           ),
           actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Color(0xFF605E5C), fontWeight: FontWeight.w700, fontSize: 11))),
              _buildFluentActionBtn('Commit Record', Iconsax.add, () {
                 if (controller.nameController.text.trim().isNotEmpty) {
                    controller.addStudentToClass();
                    Get.back();
                 }
              }),
           ],
        ),
     );
  }

  Widget _buildFluentInput(TextEditingController ctrl, String label, IconData icon) {
     return TextFormField(
        controller: ctrl,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        decoration: InputDecoration(
           labelText: label,
           labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: Colors.black.withValues(alpha: 0.4)),
           prefixIcon: Icon(icon, color: const Color(0xFF0078D4), size: 16),
           filled: true,
           fillColor: const Color(0xFFFAF9F8),
           border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
           focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF0078D4), width: 2)),
        ),
     );
  }

  void _showPicker(BuildContext context) {
     Get.bottomSheet(
        Container(
           padding: const EdgeInsets.all(24),
           decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
           child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 const Text('Select Roster Photo Source', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                 const SizedBox(height: 24),
                 _buildPickerTile('Optical Camera', Iconsax.camera, () { Get.back(); controller.pickImage(ImageSource.camera); }),
                 const SizedBox(height: 12),
                 _buildPickerTile('File Explorer', Iconsax.gallery, () { Get.back(); controller.pickImage(ImageSource.gallery); }),
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
           padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(color: const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(4)),
           child: Row(children: [Icon(icon, size: 20, color: const Color(0xFF0078D4)), const SizedBox(width: 16), Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))]),
        ),
     );
  }
}
