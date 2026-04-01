import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../../../../models/class_model.dart';
import '../../../controllers/class_controller.dart';
import '../../add_student_screen.dart';
import '../../attendance_screen.dart';

class ClassListAcademic extends StatelessWidget {
  final ClassController controller;

  const ClassListAcademic({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.academicClassic);
    const paperColor = Color(0xFFFAF7F0);
    const inkColor = Color(0xFF2D2E32);
    const accentColor = Color(0xFF8B4513); // Saddle Brown

    return Container(
      color: paperColor,
      child: Column(
        children: [
          _buildAcademicHeader(accentColor, inkColor),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.classes.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: accentColor));
              }

              if (controller.filteredClasses.isEmpty) {
                return _buildEmptyState(inkColor);
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                itemCount: controller.filteredClasses.length + (controller.hasMoreClasses.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= controller.filteredClasses.length) {
                    return _buildLoadMore(accentColor, inkColor);
                  }
                  final classItem = controller.filteredClasses[index];
                  final isSelected = controller.selectedClassIds.contains(classItem.id);
                  return _buildLedgerRow(context, classItem, isSelected, accentColor, inkColor);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicHeader(Color accent, Color ink) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAD6), // Eggshell
        border: Border(bottom: BorderSide(color: accent.withValues(alpha: 0.3), width: 1.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DEPARTMENTAL ROSTER',
            style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.w900, fontSize: 18, color: ink, letterSpacing: 0.5),
          ),
          const SizedBox(height: 16),
          _buildScribeSearch(ink),
        ],
      ),
    );
  }

  Widget _buildScribeSearch(Color ink) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ink.withValues(alpha: 0.2), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        onChanged: (v) => controller.searchClasses(v),
        style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.w600, color: ink),
        decoration: InputDecoration(
          hintText: 'FILTER BY SUBJECT MATTER...',
          hintStyle: TextStyle(fontFamily: 'Serif', color: ink.withValues(alpha: 0.4), fontSize: 12, fontWeight: FontWeight.w700),
          prefixIcon: Icon(Iconsax.search_normal, color: ink.withValues(alpha: 0.5), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildLedgerRow(BuildContext context, ClassModel classItem, bool isSelected, Color accent, Color ink) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? accent.withValues(alpha: 0.05) : Colors.white,
        border: Border.all(color: isSelected ? accent : ink.withValues(alpha: 0.15), width: isSelected ? 2 : 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onLongPress: () => controller.toggleSelectionMode(classItem.id),
        onTap: () {
          if (controller.isSelectionMode.value) {
            controller.toggleClassSelection(classItem.id);
          } else {
            Get.to(() => AttendanceScreen(classModel: classItem));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: accent, width: 1.5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (classItem.subjectName?.substring(0, 1) ?? 'C').toUpperCase(),
                        style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 20, fontFamily: 'Serif'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (classItem.subjectName ?? 'SUBJECT').toUpperCase(),
                          style: TextStyle(color: ink, fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Serif'),
                        ),
                        Text(
                          '${classItem.courseName} | SEM ${classItem.semester} | SEC ${classItem.section ?? "N/A"}'.toUpperCase(),
                          style: TextStyle(color: ink.withValues(alpha: 0.6), fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected) Icon(Iconsax.tick_circle, color: accent, size: 24),
                ],
              ),
              const SizedBox(height: 20),
              Divider(height: 1, color: accent.withValues(alpha: 0.1)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildClassicButton(Iconsax.user, 'STUDENTS', () => Get.to(() => AddStudentScreen(classModel: classItem)), accent),
                  _buildClassicButton(Iconsax.calendar, 'REGISTRY', () => Get.to(() => AttendanceScreen(classModel: classItem)), accent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassicButton(IconData icon, String label, VoidCallback onTap, Color accent) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 16, color: accent),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 11, fontFamily: 'Serif')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color ink) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.book_1, size: 64, color: ink.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text('EMPTY ROSTER', style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.w900, fontSize: 16, color: ink)),
        ],
      ),
    );
  }

  Widget _buildLoadMore(Color accent, Color ink) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: TextButton(
          onPressed: controller.loadMoreClasses,
          child: Text('LOAD ADDITIONAL ENTRIES', style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontFamily: 'Serif', fontSize: 12)),
        ),
      ),
    );
  }
}
