import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../../../../models/class_model.dart';
import '../../../controllers/class_controller.dart';
import '../../add_student_screen.dart';
import '../../attendance_screen.dart';

class ClassListNeumorphism extends StatelessWidget {
  final ClassController controller;

  const ClassListNeumorphism({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.neumorphism);
    final bgColor = const Color(0xFFE2E8F0);

    return Container(
      color: bgColor,
      child: Column(
        children: [
          _buildTopBar(bgColor),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.classes.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF94A3B8)));
              }

              if (controller.filteredClasses.isEmpty) {
                return _buildEmptyState(bgColor);
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                itemCount: controller.filteredClasses.length + (controller.hasMoreClasses.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= controller.filteredClasses.length) {
                    return _buildLoadMore(bgColor);
                  }
                  final classItem = controller.filteredClasses[index];
                  final isSelected = controller.selectedClassIds.contains(classItem.id);
                  return _buildClassCard(context, classItem, isSelected, bgColor);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(Color bgColor) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.white, offset: const Offset(-5, -5), blurRadius: 10),
            BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.5), offset: const Offset(5, 5), blurRadius: 10),
          ],
        ),
        child: TextField(
          onChanged: (v) => controller.searchClasses(v),
          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF475569)),
          decoration: InputDecoration(
            hintText: 'IDENTIFY RECORD...',
            hintStyle: TextStyle(color: const Color(0xFF475569).withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.w800),
            prefixIcon: const Icon(Iconsax.search_normal, color: Color(0xFF475569), size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, ClassModel classItem, bool isSelected, Color bgColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isSelected 
          ? [
              BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 5, inset: true),
              BoxShadow(color: const Color(0xFF94A3B8), offset: const Offset(2, 2), blurRadius: 5, inset: true),
            ]
          : [
              const BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
              BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.6), offset: const Offset(8, 8), blurRadius: 16),
            ],
      ),
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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                         const BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 6),
                         BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.5), offset: const Offset(3, 3), blurRadius: 6),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (classItem.subjectName?.substring(0, 1) ?? 'C').toUpperCase(),
                        style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 24),
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
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B)),
                        ),
                        Text(
                          '${classItem.courseName} | SEM ${classItem.semester}'.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF1E293B)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTactileButton(Iconsax.user, 'STUDENTS', () => Get.to(() => AddStudentScreen(classModel: classItem)), bgColor),
                  _buildTactileButton(Iconsax.calendar, 'ATTENDANCE', () => Get.to(() => AttendanceScreen(classModel: classItem)), bgColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTactileButton(IconData icon, String label, VoidCallback onTap, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          const BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 4),
          BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.5), offset: const Offset(2, 2), blurRadius: 4),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF475569)),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF475569))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color bgColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.box, size: 64, color: const Color(0xFF94A3B8).withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('RECORD NOT FOUND', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF475569))),
        ],
      ),
    );
  }

  Widget _buildLoadMore(Color bgColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: TextButton(
          onPressed: controller.loadMoreClasses,
          child: const Text('SYNC ADDITIONAL DATA', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
        ),
      ),
    );
  }
}
