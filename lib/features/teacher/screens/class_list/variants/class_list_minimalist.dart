import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../../../../models/class_model.dart';
import '../../../controllers/class_controller.dart';
import '../../add_student_screen.dart';
import '../../attendance_screen.dart';

class ClassListMinimalist extends StatelessWidget {
  final ClassController controller;

  const ClassListMinimalist({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.softMinimalist);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
      ),
      child: Column(
        children: [
          _buildSearchArea(tokens),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.classes.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF64748B)));
              }

              if (controller.filteredClasses.isEmpty) {
                return _buildEmptyState(tokens);
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                itemCount: controller.filteredClasses.length + (controller.hasMoreClasses.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= controller.filteredClasses.length) {
                    return _buildLoadMore(tokens);
                  }
                  final classItem = controller.filteredClasses[index];
                  final isSelected = controller.selectedClassIds.contains(classItem.id);
                  return _buildClassCard(context, classItem, isSelected, tokens);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchArea(Map<String, dynamic> tokens) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: TextField(
          onChanged: (v) => controller.searchClasses(v),
          style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: 'Search your classes...',
            hintStyle: TextStyle(color: const Color(0xFF1E293B).withOpacity(0.3), fontWeight: FontWeight.w600),
            prefixIcon: const Icon(Iconsax.search_normal, color: Color(0xFF64748B), size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, ClassModel classItem, bool isSelected, Map<String, dynamic> tokens) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isSelected ? Border.all(color: const Color(0xFF3B82F6), width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          (classItem.subjectName?.substring(0, 1) ?? 'C').toUpperCase(),
                          style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w800, fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (classItem.subjectName ?? 'Subject').toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E293B), letterSpacing: 0.5),
                          ),
                          Text(
                            '${classItem.courseName} • Sem ${classItem.semester}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF3B82F6)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildQuickAction(Iconsax.user, 'Students', () => Get.to(() => AddStudentScreen(classModel: classItem))),
                    const SizedBox(width: 12),
                    _buildQuickAction(Iconsax.calendar, 'Attendance', () => Get.to(() => AttendanceScreen(classModel: classItem))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF475569)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF475569))),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Map<String, dynamic> tokens) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.search_status, size: 60, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),
          const Text('No classes found', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF475569))),
          const Text('Try adjusting your search query', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildLoadMore(Map<String, dynamic> tokens) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: TextButton(
          onPressed: controller.loadMoreClasses,
          child: const Text('Load More Classes', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF3B82F6))),
        ),
      ),
    );
  }
}
