import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../../../../models/class_model.dart';
import '../../../controllers/class_controller.dart';
import '../../add_student/add_student_screen.dart';
import '../../attendance/attendance_screen.dart';

class ClassListBrutalist extends StatelessWidget {
  final ClassController controller;

  const ClassListBrutalist({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.brutalistBold);
    const yellow = Color(0xFFFFE14D);
    const orange = Color(0xFFFF8C42);
    const blue = Color(0xFF4D91FF);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildBrutalHeader(yellow),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.classes.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Colors.black));
              }

              if (controller.filteredClasses.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: controller.filteredClasses.length + (controller.hasMoreClasses.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= controller.filteredClasses.length) {
                    return _buildLoadMore(blue);
                  }
                  final classItem = controller.filteredClasses[index];
                  final isSelected = controller.selectedClassIds.contains(classItem.id);
                  return _buildBrutalCard(context, classItem, isSelected, index % 2 == 0 ? orange : blue);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBrutalHeader(Color bg) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: bg, border: Border.all(color: Colors.black, width: 3)),
            child: const Text('CLASS_LIST_V01', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1, fontSize: 20)),
          ),
          const SizedBox(height: 20),
          _buildBrutalSearch(),
        ],
      ),
    );
  }

  Widget _buildBrutalSearch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
      ),
      child: TextField(
        onChanged: (v) => controller.searchClasses(v),
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        decoration: const InputDecoration(
          hintText: 'FIND_RECORDS_NOW',
          hintStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14),
          prefixIcon: Icon(Iconsax.search_normal, color: Colors.black, size: 24),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildBrutalCard(BuildContext context, ClassModel classItem, bool isSelected, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        border: Border.all(color: Colors.black, width: 4),
        boxShadow: isSelected ? null : [BoxShadow(color: Colors.black, offset: const Offset(8, 8))],
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
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(color: accent, border: Border.all(color: Colors.black, width: 3)),
                    child: Center(
                      child: Text(
                        (classItem.subjectName?.substring(0, 1) ?? 'C').toUpperCase(),
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (classItem.subjectName ?? 'CLASS').toUpperCase(),
                          style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -1),
                        ),
                        Text(
                          'SEM_${classItem.semester} | SEC_${classItem.section ?? "NA"}'.toUpperCase(),
                          style: TextStyle(color: isSelected ? Colors.white.withValues(alpha: 0.8) : Colors.black, fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected) const Icon(Iconsax.tick_square5, color: Colors.white, size: 32),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildBrutalAction('STUDENTS', () => Get.to(() => AddStudentScreen(classModel: classItem)), accent, isSelected),
                  const SizedBox(width: 12),
                  _buildBrutalAction('TAKE_DATA', () => Get.to(() => AttendanceScreen(classModel: classItem)), accent, isSelected),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrutalAction(String label, VoidCallback onTap, Color accent, bool isSelected) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : accent,
            border: Border.all(color: isSelected ? Colors.white : Colors.black, width: 3),
            boxShadow: isSelected ? null : const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black, letterSpacing: 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 4), color: Colors.white),
        child: const Text('NO_DATA_FOUND', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -2)),
      ),
    );
  }

  Widget _buildLoadMore(Color accent) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: InkWell(
          onTap: controller.loadMoreClasses,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(color: accent, border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))]),
            child: const Text('LOAD_MORE_RECORDS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
          ),
        ),
      ),
    );
  }
}
