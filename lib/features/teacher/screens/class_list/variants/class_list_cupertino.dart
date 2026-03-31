import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Divider, Icons, InkWell, Color, ColorScheme, Theme, ThemeData, CircleAvatar, TextButton, FontWeight, TextStyle, BorderRadius, Radius, Offset, BoxShadow, BoxDecoration, Border, BorderSide, Widget, EdgeInsets, Column, Row, Expanded, SizedBox, BuildContext, StatelessWidget, Center, ListView, Stack, Positioned, Obx, Get, IconData, Icon, MainAxisAlignment, CrossAxisAlignment, MainAxisSize, VoidCallback, Spacer;
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../../../../models/class_model.dart';
import '../../../controllers/class_controller.dart';
import '../../add_student_screen.dart';
import '../../attendance_screen.dart';

class ClassListCupertino extends StatelessWidget {
  final ClassController controller;

  const ClassListCupertino({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.cupertinoPro);

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7), // Cupertino System Background
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('CLASSES', style: TextStyle(letterSpacing: -0.5, fontWeight: FontWeight.w800)),
            backgroundColor: const Color(0xFFF2F2F7).withOpacity(0.8),
            border: null,
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(Iconsax.refresh, size: 24),
              onPressed: () => controller.loadClasses(),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildSearchArea(),
          ),
          Obx(() {
            if (controller.isLoading.value && controller.classes.isEmpty) {
              return const SliverFillRemaining(child: Center(child: CupertinoActivityIndicator()));
            }

            if (controller.filteredClasses.isEmpty) {
              return SliverFillRemaining(child: _buildEmptyState());
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= controller.filteredClasses.length) {
                      return _buildLoadMore();
                    }
                    final classItem = controller.filteredClasses[index];
                    final isSelected = controller.selectedClassIds.contains(classItem.id);
                    return _buildClassItem(context, classItem, isSelected);
                  },
                  childCount: controller.filteredClasses.length + (controller.hasMoreClasses.value ? 1 : 0),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchArea() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CupertinoSearchTextField(
        onChanged: (v) => controller.searchClasses(v),
        placeholder: 'Search subjects...',
        borderRadius: BorderRadius.circular(12),
        backgroundColor: const Color(0xFFE3E3E8),
      ),
    );
  }

  Widget _buildClassItem(BuildContext context, ClassModel classItem, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? Border.all(color: const Color(0xFF007AFF), width: 2) : null,
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
           if (controller.isSelectionMode.value) {
            controller.toggleClassSelection(classItem.id);
          } else {
            Get.to(() => AttendanceScreen(classModel: classItem));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        (classItem.subjectName?.substring(0, 1) ?? 'C').toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
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
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: -0.2),
                        ),
                        Text(
                          '${classItem.courseName} | SEM ${classItem.semester}'.toUpperCase(),
                          style: const TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.w600, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const Icon(CupertinoIcons.chevron_right, color: Color(0xFFC7C7CC), size: 18),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFF2F2F7)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickAction(Iconsax.user, 'STUDENTS', () => Get.to(() => AddStudentScreen(classModel: classItem))),
                  _buildQuickAction(Iconsax.calendar, 'TAKE DATA', () => Get.to(() => AttendanceScreen(classModel: classItem))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onPressed: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF007AFF)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Iconsax.search_status, size: 64, color: Color(0xFFD1D1D6)),
        const SizedBox(height: 16),
        const Text('NO CLASSES FOUND', style: TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.w700, fontSize: 15)),
      ],
    );
  }

  Widget _buildLoadMore() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: CupertinoButton(
        onPressed: controller.loadMoreClasses,
        child: const Text('DISCOVER MORE RECORDS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    );
  }
}
