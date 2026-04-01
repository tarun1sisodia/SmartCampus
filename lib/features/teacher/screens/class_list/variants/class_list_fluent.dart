import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../../../../models/class_model.dart';
import '../../../controllers/class_controller.dart';
import '../../add_student_screen.dart';
import '../../attendance_screen.dart';

class ClassListFluent extends StatelessWidget {
  final ClassController controller;

  const ClassListFluent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.fluentLayered);
    const acrylicBg = Color(0xFFF3F3F3);

    return Container(
      color: acrylicBg,
      child: Column(
        children: [
          _buildAcrylicHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.classes.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF0078D4)));
              }

              if (controller.filteredClasses.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                itemCount: controller.filteredClasses.length + (controller.hasMoreClasses.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= controller.filteredClasses.length) {
                    return _buildLoadMore();
                  }
                  final classItem = controller.filteredClasses[index];
                  final isSelected = controller.selectedClassIds.contains(classItem.id);
                  return _buildFluentCard(context, classItem, isSelected);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAcrylicHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTIVE_CLASSES',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF201F1E), letterSpacing: -0.5),
          ),
          const SizedBox(height: 16),
          _buildFluentSearch(),
        ],
      ),
    );
  }

  Widget _buildFluentSearch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1), width: 1),
      ),
      child: TextField(
        onChanged: (v) => controller.searchClasses(v),
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Filter classes...',
          hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.4), fontSize: 13),
          prefixIcon: Icon(Iconsax.search_normal, color: Colors.black.withValues(alpha: 0.6), size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFluentCard(BuildContext context, ClassModel classItem, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? const Color(0xFF0078D4) : Colors.black.withValues(alpha: 0.05), 
          width: isSelected ? 2 : 1
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0078D4).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        (classItem.subjectName?.substring(0, 1) ?? 'C').toUpperCase(),
                        style: const TextStyle(color: Color(0xFF0078D4), fontWeight: FontWeight.w700, fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classItem.subjectName ?? 'Subject',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF201F1E)),
                        ),
                        Text(
                          '${classItem.courseName} | SEM ${classItem.semester}'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.black.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected) const Icon(Iconsax.tick_circle5, color: Color(0xFF0078D4), size: 24),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildFluentAction(Iconsax.user, 'Students', () => Get.to(() => AddStudentScreen(classModel: classItem))),
                  const SizedBox(width: 8),
                  _buildFluentAction(Iconsax.calendar, 'Attendance', () => Get.to(() => AttendanceScreen(classModel: classItem))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFluentAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF484644)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Color(0xFF484644), fontWeight: FontWeight.w700, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.folder_open, size: 48, color: Colors.black.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text('No classes listed', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF484644))),
        ],
      ),
    );
  }

  Widget _buildLoadMore() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: TextButton(
          onPressed: controller.loadMoreClasses,
          child: const Text('Load More Classes', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0078D4))),
        ),
      ),
    );
  }
}
