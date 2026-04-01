import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../../../../models/class_model.dart';
import '../../../controllers/class_controller.dart';
import '../../add_student_screen.dart';
import '../../attendance_screen.dart';

class ClassListCyberpunk extends StatelessWidget {
  final ClassController controller;

  const ClassListCyberpunk({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.cyberpunkNeon);
    const darkBg = Color(0xFF000814);
    const neonCyan = Color(0xFF00F5FF);
    const neonMagenta = Color(0xFFFF00CC);

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          // Grid Background
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(color: neonCyan.withValues(alpha: 0.05)),
            ),
          ),
          
          Column(
            children: [
              _buildHUDHeader(neonCyan, neonMagenta),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.classes.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: neonCyan));
                  }

                  if (controller.filteredClasses.isEmpty) {
                    return _buildEmptyState(neonCyan);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: controller.filteredClasses.length + (controller.hasMoreClasses.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= controller.filteredClasses.length) {
                        return _buildLoadMore(neonCyan);
                      }
                      final classItem = controller.filteredClasses[index];
                      final isSelected = controller.selectedClassIds.contains(classItem.id);
                      return _buildCyberCard(context, classItem, isSelected, neonCyan, neonMagenta);
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

  Widget _buildHUDHeader(Color cyan, Color magenta) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: cyan.withValues(alpha: 0.05),
        border: Border(bottom: BorderSide(color: cyan, width: 2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SYSTEM_DIRECTORY',
                style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2.0, shadows: [Shadow(color: cyan, blurRadius: 10)]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(border: Border.all(color: magenta)),
                child: Obx(() => Text(
                  '${controller.classes.length} NODES_ACTIVE',
                  style: TextStyle(color: magenta, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1),
                )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTerminalSearch(cyan),
        ],
      ),
    );
  }

  Widget _buildTerminalSearch(Color cyan) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: cyan.withValues(alpha: 0.5)),
      ),
      child: TextField(
        onChanged: (v) => controller.searchClasses(v),
        style: TextStyle(color: cyan, fontWeight: FontWeight.w700, fontFamily: 'Courier', letterSpacing: 1),
        decoration: InputDecoration(
          hintText: '> SEARCH_QUERY_ENTER...',
          hintStyle: TextStyle(color: cyan.withValues(alpha: 0.2), fontWeight: FontWeight.w700, fontSize: 12),
          prefixIcon: Icon(Iconsax.search_normal, color: cyan, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCyberCard(BuildContext context, ClassModel classItem, bool isSelected, Color cyan, Color magenta) {
    final activeColor = isSelected ? magenta : cyan;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: activeColor, width: 2),
        boxShadow: [
          BoxShadow(color: activeColor.withValues(alpha: 0.2), blurRadius: 15, spreadRadius: 1),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(color: activeColor),
                    ),
                    child: Center(
                      child: Text(
                        (classItem.subjectName?.substring(0, 1) ?? 'C').toUpperCase(),
                        style: TextStyle(color: activeColor, fontWeight: FontWeight.w900, fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (classItem.subjectName ?? 'NODE').toUpperCase(),
                          style: TextStyle(color: activeColor, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
                        ),
                        Text(
                          'LVL: ${classItem.semester} | SECTOR: ${classItem.courseName}'.toUpperCase(),
                          style: TextStyle(color: activeColor.withValues(alpha: 0.5), fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected) Icon(Iconsax.flash, color: magenta, size: 28),
                ],
              ),
              const SizedBox(height: 20),
              Container(height: 1, color: activeColor.withValues(alpha: 0.2)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildHUDButton(Iconsax.user, 'INIT_STUDENTS', () => Get.to(() => AddStudentScreen(classModel: classItem)), activeColor),
                  _buildHUDButton(Iconsax.calendar, 'RUN_ATTENDANCE', () => Get.to(() => AttendanceScreen(classModel: classItem)), activeColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHUDButton(IconData icon, String label, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          color: color.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color cyan) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.warning_2, size: 64, color: cyan.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('ZERO_NODES_ALLOCATED', style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildLoadMore(Color cyan) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: OutlinedButton(
        onPressed: controller.loadMoreClasses,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: cyan),
          backgroundColor: cyan.withValues(alpha: 0.05),
        ),
        child: Text('LOAD_ADDITIONAL_BUFFERS', style: TextStyle(color: cyan, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const double step = 30.0;
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
