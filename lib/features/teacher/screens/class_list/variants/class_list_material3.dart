import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../models/class_model.dart';
import '../../../controllers/class_controller.dart';
import '../../add_student_screen.dart';
import '../../attendance_screen.dart';
class ClassListMaterial3 extends StatelessWidget {
  final ClassController controller;

  const ClassListMaterial3({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          _buildSearchHeader(theme),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.classes.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredClasses.isEmpty) {
                return _buildEmptyState(theme);
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: controller.filteredClasses.length + (controller.hasMoreClasses.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= controller.filteredClasses.length) {
                    return _buildLoadMore(theme);
                  }
                  final classItem = controller.filteredClasses[index];
                  final isSelected = controller.selectedClassIds.contains(classItem.id);
                  return _buildClassCard(context, classItem, isSelected, theme);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SearchBar(
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
        hintText: 'Search classes...',
        onChanged: (v) => controller.searchClasses(v),
        leading: const Icon(Iconsax.search_normal_1, size: 20),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, ClassModel classItem, bool isSelected, ThemeData theme) {
    return Card(
      elevation: isSelected ? 4 : 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected 
          ? theme.colorScheme.secondaryContainer 
          : theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: isSelected 
            ? BorderSide(color: theme.colorScheme.primary, width: 2) 
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
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
                   CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      (classItem.subjectName?.substring(0, 1) ?? 'C').toUpperCase(),
                      style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.w900, fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classItem.subjectName ?? 'Subject',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
                        ),
                        Text(
                          '${classItem.courseName} • Sem ${classItem.semester}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected) Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 28),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                   _buildChip(theme, Iconsax.user, 'Students', () => Get.to(() => AddStudentScreen(classModel: classItem))),
                   const SizedBox(width: 8),
                   _buildChip(theme, Iconsax.calendar, 'Attendance', () => Get.to(() => AttendanceScreen(classModel: classItem))),
                   const Spacer(),
                   IconButton.filledTonal(
                    onPressed: () => Get.to(() => AttendanceScreen(classModel: classItem)), 
                    icon: const Icon(Iconsax.arrow_right_3, size: 18)
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(ThemeData theme, IconData icon, String label, VoidCallback onTap) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(icon, size: 14, color: theme.colorScheme.onSecondaryContainer),
      label: Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: theme.colorScheme.onSecondaryContainer)),
      backgroundColor: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.radar, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text('Nothing here', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          Text('Try searching something else', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildLoadMore(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: FilledButton.tonal(
          onPressed: controller.loadMoreClasses,
          child: const Text('Load More Classes'),
        ),
      ),
    );
  }
}
