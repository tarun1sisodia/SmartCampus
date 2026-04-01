import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_campus/common/ui_patterns/pattern_tokens.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';
import 'package:smart_campus/models/class_model.dart';
import 'package:smart_campus/features/teacher/controllers/class_controller.dart';
import 'package:smart_campus/features/teacher/screens/add_student/add_student_screen.dart';
import 'package:smart_campus/features/teacher/screens/attendance/attendance_screen.dart';

class ClassListCorporate extends StatelessWidget {
  final ClassController controller;

  const ClassListCorporate({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.industrialCorporate);

    return Column(
      children: [
        _buildHeader(tokens),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.classes.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)));
            }

            if (controller.filteredClasses.isEmpty) {
              return _buildEmptyState(tokens);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(24),
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
    );
  }

  Widget _buildHeader(PatternTokens tokens) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'INSTITUTIONAL DIRECTORY',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2.0),
              ),
              Obx(() => Text(
                '${controller.classes.length} ACTIVE RECORDS',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w800, fontSize: 10),
              )),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchBar(tokens),
        ],
      ),
    );
  }

  Widget _buildSearchBar(PatternTokens tokens) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
        borderRadius: BorderRadius.zero,
      ),
      child: TextField(
        onChanged: (v) => controller.searchClasses(v),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          hintText: 'SEARCH CLASS RECORDS...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontWeight: FontWeight.w800, fontSize: 13),
          prefixIcon: Icon(Iconsax.search_normal, color: Colors.white.withValues(alpha: 0.5), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, ClassModel classItem, bool isSelected, PatternTokens tokens) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0), 
          width: isSelected ? 3.0 : 1.5
        ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      border: Border.all(color: const Color(0xFF0F172A), width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        (classItem.subjectName?.substring(0, 1) ?? 'C').toUpperCase(),
                        style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (classItem.subjectName ?? 'UNKNOWN SUBJECT').toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A), letterSpacing: -0.5),
                        ),
                        Text(
                          '${classItem.courseName} | SEM ${classItem.semester} | SEC ${classItem.section ?? "N/A"}'.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Color(0xFF64748B), letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected) const Icon(Icons.check_box, color: Color(0xFF0F172A)),
                ],
              ),
              const SizedBox(height: 20),
              Container(height: 1.5, color: const Color(0xFFF1F5F9)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStat(Iconsax.people, 'STUDENTS', () => Get.to(() => AddStudentScreen(classModel: classItem))),
                  const Spacer(),
                  _buildStat(Iconsax.calendar, 'ATTENDANCE', () => Get.to(() => AttendanceScreen(classModel: classItem))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0F172A)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(PatternTokens tokens) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.folder_open, size: 64, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          const Text(
            'NO MATCHING RECORDS',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
          ),
          Text(
            'PLEASE ADJUST YOUR SEARCH PARAMETERS.',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: const Color(0xFF0F172A).withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMore(PatternTokens tokens) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: OutlinedButton(
          onPressed: controller.loadMoreClasses,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF0F172A), width: 1.5),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: const Text('LOAD ADDITIONAL RECORDS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
        ),
      ),
    );
  }
}
