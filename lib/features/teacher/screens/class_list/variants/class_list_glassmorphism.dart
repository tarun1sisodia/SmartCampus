import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../../../../models/class_model.dart';
import '../../../controllers/class_controller.dart';
import '../../add_student_screen.dart';
import '../../attendance_screen.dart';

class ClassListGlassmorphism extends StatelessWidget {
  final ClassController controller;

  const ClassListGlassmorphism({super.key, required this.controller});

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
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.white.withValues(alpha: 0.05)),
            ),
          ),
          
          Column(
            children: [
              _buildHeader(tokens),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.classes.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }

                  if (controller.filteredClasses.isEmpty) {
                    return _buildEmptyState(tokens);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> tokens) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'GLASS CAMPUS',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.0),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Obx(() => Text(
                  '${controller.classes.length} LECTURES',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10),
                )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchBar(tokens),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Map<String, dynamic> tokens) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: TextField(
            onChanged: (v) => controller.searchClasses(v),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'FILTER THROUGH THE UNIVERSE...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, fontWeight: FontWeight.w700),
              prefixIcon: const Icon(Iconsax.search_normal, color: Colors.white, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, ClassModel classItem, bool isSelected, Map<String, dynamic> tokens) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.15), 
                width: isSelected ? 2.5 : 1
              ),
              boxShadow: [
                 if (isSelected) BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
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
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF60A5FA), Color(0xFFC084FC)]),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: const Color(0xFF60A5FA).withValues(alpha: 0.3), blurRadius: 10)],
                          ),
                          child: Center(
                            child: Text(
                              (classItem.subjectName?.substring(0, 1) ?? 'C').toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24),
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
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                              Text(
                                '${classItem.courseName} | SEM ${classItem.semester}'.toUpperCase(),
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w700, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected) const Icon(Iconsax.tick_circle5, color: Colors.white, size: 28),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildGlassChip(Iconsax.user, 'STUDENTS', () => Get.to(() => AddStudentScreen(classModel: classItem))),
                        _buildGlassChip(Iconsax.calendar, 'ATTENDANCE', () => Get.to(() => AttendanceScreen(classModel: classModel))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassChip(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10)),
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
          Icon(Iconsax.radar, size: 64, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('NOTHING FOUND IN SPACE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
          Text('WIDEN YOUR PARAMETERS', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w700, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildLoadMore(Map<String, dynamic> tokens) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: TextButton(
          onPressed: controller.loadMoreClasses,
          child: const Text('DISCOVER MORE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ),
      ),
    );
  }
}
