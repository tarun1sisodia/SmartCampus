import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/student_controller.dart';
import '../../../../../common/widgets/student_avatar.dart';
import '../../../../models/class_model.dart';

class AddStudentBrutalist extends StatelessWidget {
  final StudentController controller;
  final ClassModel classModel;

  const AddStudentBrutalist({super.key, required this.controller, required this.classModel});

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFE14D);
    const orange = Color(0xFFFF8C42);
    const blue = Color(0xFF4D91FF);

    return Container(
      color: Colors.white,
      child: Obx(() {
        if (controller.isLoading.value) {
           return const Center(child: CircularProgressIndicator(color: Colors.black));
        }

        if (controller.students.isEmpty) {
           return _buildBrutalEmpty(context, yellow);
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
              return _buildBrutalStudentCard(context, student, blue, orange);
            },
          ),
        );
      }),
    );
  }

  Widget _buildBrutalEmpty(BuildContext context, Color yellow) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.user_add, size: 80, color: Colors.black12),
            const SizedBox(height: 24),
            const Text('ROSTER_MANIFEST_VOID', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
               onPressed: () => _showAddDialog(context, yellow),
               icon: const Icon(Iconsax.add, size: 20),
               label: const Text('ADD_STUDENT_01'),
               style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrutalStudentCard(BuildContext context, dynamic student, Color blue, Color orange) {
    final isSelected = controller.selectedStudentIds.contains(student.id);
    final isSelectionMode = controller.isSelectionMode.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: [BoxShadow(color: isSelected ? blue : Colors.black, offset: const Offset(4, 4))],
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
            ? _buildBrutalCheckbox(isSelected, blue)
            : StudentAvatar(imageUrl: student.imageUrl, name: student.name, size: 48, isDarkMode: false),
         title: Text(student.name.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.black)),
         subtitle: Text('ID_NODE: ${student.rollNumber}'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Colors.black54)),
         trailing: !isSelectionMode 
            ? IconButton(icon: Icon(Iconsax.trash, size: 20, color: orange), onPressed: () => controller.removeStudentFromClass(student.id))
            : null,
      ),
    );
  }

  Widget _buildBrutalCheckbox(bool isSelected, Color blue) {
    return Container(
      width: 24, height: 24,
      decoration: BoxDecoration(color: isSelected ? blue : Colors.white, border: Border.all(color: Colors.black, width: 2.5)),
      child: isSelected ? const Icon(Icons.check, size: 18, color: Colors.black) : null,
    );
  }

  void _showAddDialog(BuildContext context, Color yellow) {
     controller.nameController.clear();
     controller.rollNumberController.clear();
     controller.clearSelectedImage();

     Get.dialog(
        AlertDialog(
           backgroundColor: Colors.white,
           shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero, border: Border.all(color: Colors.black, width: 3)),
           title: const Text('ENROLL_STUDENT_DATA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black)),
           content: SingleChildScrollView(
              child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                    Obx(() => GestureDetector(
                       onTap: () => _showPicker(context),
                       child: Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(color: yellow, border: Border.all(color: Colors.black, width: 2.5), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))]),
                          child: controller.selectedImage.value != null 
                             ? Image.file(controller.selectedImage.value!, fit: BoxFit.cover)
                             : const Icon(Iconsax.camera, color: Colors.black, size: 28),
                       ),
                    )),
                    const SizedBox(height: 32),
                    _buildBrutalInput(controller.nameController, 'IDENTIFIER_NAME', Iconsax.user),
                    const SizedBox(height: 20),
                    _buildBrutalInput(controller.rollNumberController, 'DATA_NODE_ROLL', Iconsax.hashtag),
                 ],
              ),
           ),
           actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('DISCARD', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w900, fontSize: 11))),
              ElevatedButton(
                 onPressed: () {
                    if (controller.nameController.text.trim().isNotEmpty) {
                       controller.addStudentToClass();
                       Get.back();
                    }
                 },
                 style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: Colors.black, width: 2))),
                 child: const Text('COMMIT_01'),
              ),
           ],
        ),
     );
  }

  Widget _buildBrutalInput(TextEditingController ctrl, String label, IconData icon) {
     return Container(
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black, width: 3))),
        child: TextFormField(
           controller: ctrl,
           style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
           decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.black38),
              prefixIcon: Icon(icon, color: Colors.black, size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
           ),
        ),
     );
  }

  void _showPicker(BuildContext context) {
     Get.bottomSheet(
        Container(
           padding: const EdgeInsets.all(32),
           decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black, width: 4))),
           child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 const Text('SOURCE_BUFFER_SELECTION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                 const SizedBox(height: 24),
                 _buildSourceTile('CAMERA_UNIT', Iconsax.camera, () { Get.back(); controller.pickImage(ImageSource.camera); }),
                 const SizedBox(height: 12),
                 _buildSourceTile('STORAGE_IMPORT', Iconsax.gallery, () { Get.back(); controller.pickImage(ImageSource.gallery); }),
                 const SizedBox(height: 16),
              ],
           ),
        ),
     );
  }

  Widget _buildSourceTile(String label, IconData icon, VoidCallback onTap) {
     return InkWell(
        onTap: onTap,
        child: Container(
           padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2), color: Colors.white, boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))]),
           child: Row(children: [Icon(icon, size: 20, color: Colors.black), const SizedBox(width: 16), Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12))]),
        ),
     );
  }
}
