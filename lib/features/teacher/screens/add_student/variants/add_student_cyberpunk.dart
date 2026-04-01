import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/student_controller.dart';
import '../../../../../common/widgets/student_avatar.dart';
import '../../../../models/class_model.dart';

class AddStudentCyberpunk extends StatelessWidget {
  final StudentController controller;
  final ClassModel classModel;

  const AddStudentCyberpunk({super.key, required this.controller, required this.classModel});

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF000814);
    const cyan = Color(0xFF00F5FF);
    const magenta = Color(0xFFFF00CC);

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          _buildHUDGrid(cyan),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: cyan));
            }

            if (controller.students.isEmpty) {
              return _buildCyberEmpty(context, cyan);
            }

            return RefreshIndicator(
              onRefresh: () => controller.loadStudentsForClass(classModel.id),
              child: ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: controller.students.length + (controller.isLoadingMoreStudents.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.students.length) {
                    return const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: CircularProgressIndicator(color: cyan)));
                  }
                  final student = controller.students[index];
                  return _buildCyberStudentCard(context, student, cyan, magenta);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHUDGrid(Color cyan) {
    return Positioned.fill(
      child: CustomPaint(
        painter: GridPainter(color: cyan.withValues(alpha: 0.04)),
      ),
    );
  }

  Widget _buildCyberEmpty(BuildContext context, Color cyan) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.user_add, size: 80, color: cyan.withValues(alpha: 0.3)),
          const SizedBox(height: 24),
          Text('TERMINAL_MANIFEST_EMPTY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: cyan, letterSpacing: 2, fontFamily: 'Courier')),
          const SizedBox(height: 40),
          _buildCyberActionBtn('INITIALIZE_UPLINK', Iconsax.add_circle, () => _showAddDialog(context, cyan, Color(0xFFFF00CC))),
        ],
      ),
    );
  }

  Widget _buildCyberActionBtn(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFF00F5FF), width: 1.5), color: const Color(0xFF00F5FF).withValues(alpha: 0.05)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF00F5FF), size: 16),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Color(0xFF00F5FF), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1, fontFamily: 'Courier')),
          ],
        ),
      ),
    );
  }

  Widget _buildCyberStudentCard(BuildContext context, dynamic student, Color cyan, Color magenta) {
    final isSelected = controller.selectedStudentIds.contains(student.id);
    final isSelectionMode = controller.isSelectionMode.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: isSelected ? cyan : cyan.withValues(alpha: 0.2), width: isSelected ? 2 : 1),
        boxShadow: isSelected ? [BoxShadow(color: cyan.withValues(alpha: 0.15), blurRadius: 10)] : null,
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
            ? _buildCyberCheckbox(isSelected, cyan)
            : StudentAvatar(imageUrl: student.imageUrl, name: student.name, size: 48, isDarkMode: true),
         title: Text(student.name.toString().toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: cyan, letterSpacing: 0.5, fontFamily: 'Courier')),
         subtitle: Text('NODE_ID: ${student.rollNumber}'.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 9, color: cyan.withValues(alpha: 0.4), fontFamily: 'Courier')),
         trailing: !isSelectionMode 
            ? IconButton(icon: Icon(Iconsax.trash, size: 18, color: magenta.withValues(alpha: 0.5)), onPressed: () => controller.removeStudentFromClass(student.id))
            : null,
      ),
    );
  }

  Widget _buildCyberCheckbox(bool isSelected, Color cyan) {
    return Container(
      width: 24, height: 24,
      decoration: BoxDecoration(color: isSelected ? cyan : Colors.transparent, border: Border.all(color: cyan, width: 2)),
      child: isSelected ? const Icon(Icons.check, size: 18, color: Colors.black) : null,
    );
  }

  void _showAddDialog(BuildContext context, Color cyan, Color magenta) {
     controller.nameController.clear();
     controller.rollNumberController.clear();
     controller.clearSelectedImage();

     Get.dialog(
        AlertDialog(
           backgroundColor: Colors.black,
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, border: Border.all(color: cyan, width: 2)),
           title: Text('ENROLLMENT_TERMINAL_V1', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: cyan, letterSpacing: 1, fontFamily: 'Courier')),
           content: SingleChildScrollView(
              child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                    Obx(() => GestureDetector(
                       onTap: () => _showPicker(context, cyan, magenta),
                       child: Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(color: Colors.black, border: Border.all(color: cyan, width: 1.5)),
                          child: controller.selectedImage.value != null 
                             ? Image.file(controller.selectedImage.value!, fit: BoxFit.cover)
                             : Icon(Iconsax.camera, color: cyan, size: 32),
                       ),
                    )),
                    const SizedBox(height: 24),
                    _buildCyberInput(controller.nameController, 'IDENTIFIER_NAME', Iconsax.user, cyan),
                    const SizedBox(height: 12),
                    _buildCyberInput(controller.rollNumberController, 'DATA_NODE_ROLL', Iconsax.hashtag, cyan),
                 ],
              ),
           ),
           actions: [
              TextButton(onPressed: () => Get.back(), child: Text('TERMINATE', style: TextStyle(color: magenta.withValues(alpha: 0.5), fontWeight: FontWeight.w900, fontSize: 10, fontFamily: 'Courier'))),
              ElevatedButton(
                 onPressed: () {
                    if (controller.nameController.text.trim().isNotEmpty) {
                       controller.addStudentToClass();
                       Get.back();
                    }
                 },
                 style: ElevatedButton.styleFrom(backgroundColor: cyan, foregroundColor: Colors.black, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                 child: const Text('COMMIT_NODE'),
              ),
           ],
        ),
     );
  }

  Widget _buildCyberInput(TextEditingController ctrl, String label, IconData icon, Color cyan) {
     return Container(
        decoration: BoxDecoration(border: Border.all(color: cyan.withValues(alpha: 0.2)), color: cyan.withValues(alpha: 0.02)),
        child: TextFormField(
           controller: ctrl,
           style: TextStyle(color: cyan, fontWeight: FontWeight.w800, fontSize: 13, fontFamily: 'Courier'),
           decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: cyan.withValues(alpha: 0.4), fontWeight: FontWeight.w900, fontSize: 9, fontFamily: 'Courier'),
              prefixIcon: Icon(icon, color: cyan, size: 16),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
           ),
        ),
     );
  }

  void _showPicker(BuildContext context, Color cyan, Color magenta) {
     Get.bottomSheet(
        Container(
           padding: const EdgeInsets.all(32),
           color: Colors.black,
           child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 Text('SOURCE_SELECTION', style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'Courier')),
                 const SizedBox(height: 24),
                 _buildPickerTile('CAMERA_UNIT', Iconsax.camera, cyan, () { Get.back(); controller.pickImage(ImageSource.camera); }),
                 _buildPickerTile('STORAGE_BUFFER', Iconsax.gallery, cyan, () { Get.back(); controller.pickImage(ImageSource.gallery); }),
                 const SizedBox(height: 20),
              ],
           ),
        ),
     );
  }

  Widget _buildPickerTile(String label, IconData icon, Color cyan, VoidCallback onTap) {
     return InkWell(
        onTap: onTap,
        child: Container(
           margin: const EdgeInsets.only(bottom: 12),
           padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(border: Border.all(color: cyan.withValues(alpha: 0.3)), color: cyan.withValues(alpha: 0.02)),
           child: Row(children: [Icon(icon, color: cyan, size: 20), const SizedBox(width: 16), Text(label, style: TextStyle(color: cyan, fontWeight: FontWeight.w800, fontSize: 12, fontFamily: 'Courier'))]),
        ),
     );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1.0;
    const double step = 40.0;
    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
