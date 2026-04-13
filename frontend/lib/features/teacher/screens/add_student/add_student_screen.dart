import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:smart_campus/common/ui_patterns/pattern_scaffold.dart';
import 'package:smart_campus/common/ui_patterns/ui_style_controller.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';
import 'package:smart_campus/common/utils/constants/colors.dart';
import 'package:smart_campus/models/class_model.dart';
import 'package:smart_campus/features/teacher/controllers/student_controller.dart';
import 'variants/add_student_academic.dart';
import 'variants/add_student_brutalist.dart';
import 'variants/add_student_corporate.dart';
import 'variants/add_student_cupertino.dart';
import 'variants/add_student_cyberpunk.dart';
import 'variants/add_student_fluent.dart';
import 'variants/add_student_glassmorphism.dart';
import 'variants/add_student_material3.dart';
import 'variants/add_student_minimalist.dart';
import 'variants/add_student_neumorphic.dart';

class AddStudentScreen extends StatelessWidget {
  final ClassModel classModel;
  final studentController = Get.put(StudentController());

  AddStudentScreen({super.key, required this.classModel});

  @override
  Widget build(BuildContext context) {
    final uiController = UIStyleController.instance;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      studentController.setSelectedClass(classModel);
    });

    return Obx(() {
      final style = uiController.currentStyle.value;
      final isSelectionMode = studentController.isSelectionMode.value;
      final selectedCount = studentController.selectedStudentIds.length;

      return PatternScaffold(
        title: isSelectionMode ? '$selectedCount SELECTED' : 'MANAGE ROSTER',
        leading: isSelectionMode 
           ? IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => studentController.toggleSelectionMode())
           : null,
        actions: [
           if (isSelectionMode)
              IconButton(icon: const Icon(Icons.select_all), onPressed: () => studentController.toggleSelectAll())
           else
              IconButton(icon: const Icon(Iconsax.import), onPressed: () => _showImportStudentsDialog(context)),
        ],
        floatingActionButton: FloatingActionButton.extended(
           onPressed: () {
              if (isSelectionMode) {
                 if (studentController.selectedStudentIds.isNotEmpty) {
                    _showDeleteSelectedConfirmation(context);
                 }
              } else {
                 _showAddStudentDialog(context);
              }
           },
           backgroundColor: isSelectionMode ? Colors.red : TColors.executiveNavy,
           foregroundColor: Colors.white,
           icon: Icon(isSelectionMode ? Iconsax.trash : Iconsax.user_add, size: 20),
           label: Text(isSelectionMode ? 'DELETE' : 'ENROLL', style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        ),
        body: _buildVariant(style),
      );
    });
  }

  Widget _buildVariant(UIStyle style) {
    switch (style) {
      case UIStyle.industrialCorporate:
        return AddStudentCorporate(controller: studentController, classModel: classModel);
      case UIStyle.softMinimalist:
        return AddStudentMinimalist(controller: studentController, classModel: classModel);
      case UIStyle.glassmorphism:
        return AddStudentGlassmorphism(controller: studentController, classModel: classModel);
      case UIStyle.neumorphism:
        return AddStudentNeumorphism(controller: studentController, classModel: classModel);
      case UIStyle.material3:
        return AddStudentMaterial3(controller: studentController, classModel: classModel);
      case UIStyle.cupertinoPro:
        return AddStudentCupertino(controller: studentController, classModel: classModel);
      case UIStyle.cyberpunkNeon:
        return AddStudentCyberpunk(controller: studentController, classModel: classModel);
      case UIStyle.brutalistBold:
        return AddStudentBrutalist(controller: studentController, classModel: classModel);
      case UIStyle.academicClassic:
        return AddStudentAcademic(controller: studentController, classModel: classModel);
      case UIStyle.fluentLayered:
        return AddStudentFluent(controller: studentController, classModel: classModel);
    }
  }

  // --- Core Dialog Helpers Moved from Old Screen Logic ---

  void _showAddStudentDialog(BuildContext context) {
    // This is handled per-variant for aesthetic consistency, 
    // but we can provide a default trigger if a variant doesn't implement its own.
    // However, all variants created so far have their own _showAddDialog.
    // For manual FAB trigge, we'll use a generic corporate dialog as fallback.
    _showCorporateDialog(context, title: 'ENROLL STUDENT', content: const Text('Initialize manual enrollment entry.'), confirmLabel: 'PROCEED', onConfirm: () => Get.back());
  }

  void _showDeleteSelectedConfirmation(BuildContext context) {
    final count = studentController.selectedStudentIds.length;
    _showCorporateDialog(
      context,
      title: 'DELETE SELECTED',
      content: Text('Permanently remove $count student(s) from this class?'),
      confirmLabel: 'DELETE',
      onConfirm: () {
        studentController.removeSelectedStudentsFromClass();
        Get.back();
      },
      isDestructive: true,
    );
  }

  void _showImportStudentsDialog(BuildContext context) {
    studentController.fetchAvailableStudents();
    final searchController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text('IMPORT FROM GLOBAL ROSTER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Obx(() {
            if (studentController.isFetchingAvailableStudents.value) return const Center(child: CircularProgressIndicator());
            
            final filtered = studentController.availableStudents.where((s) => s.name.toLowerCase().contains(searchController.text.toLowerCase())).toList();

            return Column(
              children: [
                TextField(controller: searchController, decoration: const InputDecoration(labelText: 'Search students...', prefixIcon: Icon(Iconsax.search_normal)), onChanged: (v) => studentController.availableStudents.refresh()),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final s = filtered[index];
                      final sel = studentController.selectedStudents.any((x) => x.id == s.id);
                      return CheckboxListTile(
                        value: sel,
                        onChanged: (v) => v == true ? studentController.selectStudent(s) : studentController.deselectStudent(s),
                        title: Text(s.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text('ROLL: ${s.rollNumber}'),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('CANCEL')),
          ElevatedButton(onPressed: () { studentController.importSelectedStudents(); Get.back(); }, child: const Text('IMPORT')),
        ],
      ),
    );
  }

  void _showCorporateDialog(BuildContext context, {required String title, required Widget content, required String confirmLabel, required VoidCallback onConfirm, bool isDestructive = false}) {
    Get.dialog(
      AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: TColors.executiveNavy, width: 2.0)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        content: content,
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(backgroundColor: isDestructive ? Colors.red : TColors.executiveNavy),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
