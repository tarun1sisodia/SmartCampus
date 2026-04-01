import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/student_controller.dart';
import '../../../../../common/widgets/student_avatar.dart';
import '../../../../models/class_model.dart';

class AddStudentGlassmorphism extends StatelessWidget {
  final StudentController controller;
  final ClassModel classModel;

  const AddStudentGlassmorphism({super.key, required this.controller, required this.classModel});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.glassmorphism);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dynamic Mesh Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6366F1), Color(0xFFA855F7), Color(0xFFEC4899)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(color: Colors.black.withValues(alpha: 0.05)),
            ),
          ),

          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            if (controller.students.isEmpty) {
              return _buildGlassEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () => controller.loadStudentsForClass(classModel.id),
              child: ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                itemCount: controller.students.length + (controller.isLoadingMoreStudents.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.students.length) {
                    return const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: CircularProgressIndicator(color: Colors.white)));
                  }
                  final student = controller.students[index];
                  return _buildGlassStudentCard(context, student);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGlassEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.user_add, size: 80, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 24),
          const Text('ROSTER_VOID_NODE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: 1)),
          const SizedBox(height: 32),
          _buildGlassActionBtn('INITIALIZE_ENROLLMENT', Iconsax.add, () => _showAddDialog(context)),
        ],
      ),
    );
  }

  Widget _buildGlassActionBtn(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
       onTap: onTap,
       child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), border: Border.all(color: Colors.white.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(16)),
          child: Row(
             mainAxisSize: MainAxisSize.min,
             children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 12),
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
             ],
          ),
       ),
    );
  }

  Widget _buildGlassStudentCard(BuildContext context, dynamic student) {
    final isSelected = controller.selectedStudentIds.contains(student.id);
    final isSelectionMode = controller.isSelectionMode.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2), width: isSelected ? 2 : 1),
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
            ? _buildGlassCheckbox(isSelected)
            : StudentAvatar(imageUrl: student.imageUrl, name: student.name, size: 48, isDarkMode: true),
         title: Text(student.name.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white, letterSpacing: 0.5)),
         subtitle: Text('NODE_ID: ${student.rollNumber}'.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 9, color: Colors.white.withValues(alpha: 0.5))),
         trailing: !isSelectionMode 
            ? IconButton(icon: const Icon(Iconsax.trash, size: 18, color: Colors.white60), onPressed: () => controller.removeStudentFromClass(student.id))
            : null,
      ),
    );
  }

  Widget _buildGlassCheckbox(bool isSelected) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: isSelected ? Colors.white : Colors.transparent, border: Border.all(color: Colors.white, width: 2), borderRadius: BorderRadius.circular(8)),
      child: isSelected ? const Icon(Icons.check, size: 18, color: Color(0xFFA855F7)) : null,
    );
  }

  void _showAddDialog(BuildContext context) {
    controller.nameController.clear();
    controller.rollNumberController.clear();
    controller.clearSelectedImage();

    Get.dialog(
       BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
             backgroundColor: Colors.white.withValues(alpha: 0.1),
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.white.withValues(alpha: 0.2))),
             title: const Text('ENROLLMENT_UPLINK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: 1)),
             content: SingleChildScrollView(
                child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                      Obx(() => GestureDetector(
                         onTap: () => _showPicker(context),
                         child: Container(
                            width: 100, height: 100,
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), border: Border.all(color: Colors.white.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(24)),
                            child: controller.selectedImage.value != null 
                               ? ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.file(controller.selectedImage.value!, fit: BoxFit.cover))
                               : const Icon(Iconsax.camera, color: Colors.white, size: 32),
                         ),
                      )),
                      const SizedBox(height: 24),
                      _buildGlassInput(controller.nameController, 'FULL_NAME', Iconsax.user),
                      const SizedBox(height: 16),
                      _buildGlassInput(controller.rollNumberController, 'ROLL_NUMBER', Iconsax.hashtag),
                   ],
                ),
             ),
             actions: [
                TextButton(onPressed: () => Get.back(), child: const Text('DISCONNECT', style: TextStyle(color: Colors.white60, fontWeight: FontWeight.w800, fontSize: 11))),
                ElevatedButton(
                   onPressed: () {
                      if (controller.nameController.text.trim().isNotEmpty) {
                         controller.addStudentToClass();
                         Get.back();
                      }
                   },
                   style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.15), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white30))),
                   child: const Text('COMMIT_NODE'),
                ),
             ],
          ),
       ),
    );
  }

  Widget _buildGlassInput(TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
       controller: ctrl,
       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
       decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontWeight: FontWeight.w900, fontSize: 9),
          prefixIcon: Icon(icon, color: Colors.white, size: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white, width: 1.5)),
       ),
    );
  }

  void _showPicker(BuildContext context) {
    Get.bottomSheet(
       Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: const Color(0xFF1E1B4B), borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), border: Border.all(color: Colors.white10)),
          child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
                const Text('TERMINAL_SOURCE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 24),
                _buildSourceTile('CAMERA', Iconsax.camera, () { Get.back(); controller.pickImage(ImageSource.camera); }),
                _buildSourceTile('STORAGE', Iconsax.gallery, () { Get.back(); controller.pickImage(ImageSource.gallery); }),
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
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
          child: Row(children: [Icon(icon, color: Colors.white), const SizedBox(width: 16), Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
       ),
    );
  }
}
