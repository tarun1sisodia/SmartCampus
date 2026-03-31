import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/routes/app_routes.dart';
import '../../../common/utils/constants/text_strings.dart';
import '../../../models/class_model.dart';
import '../../../models/subject_model.dart';
import '../controllers/class_controller.dart';
import '../../../common/utils/constants/sized.dart';
import 'add_student_screen.dart';
import 'attendance_screen.dart';
import 'create_class_screen.dart';

class ClassListScreen extends StatelessWidget {
  final classController = Get.put(ClassController());
  final searchController = TextEditingController();
  final RxBool isSearching = RxBool(false);

  ClassListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            classController.isSelectionMode.value
                ? '${classController.selectedClassIds.length} Selected'
                : 'My Classes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          leading: classController.isSelectionMode.value
              ? IconButton(
                  onPressed: () {
                    classController.toggleSelectionMode(null);
                  },
                  icon: const Icon(Icons.close),
                )
              : null,
          actions: [
            if (classController.isSelectionMode.value)
              IconButton(
                onPressed: () {
                  classController.toggleSelectAll();
                },
                icon: Icon(
                  classController.isAllSelected.value
                      ? Icons.select_all
                      : Icons.select_all_outlined,
                ),
              ),
            if (!classController.isSelectionMode.value) ...[
              IconButton(
                onPressed: () {
                  classController.loadClasses();
                },
                icon: const Icon(Iconsax.refresh),
                tooltip: 'Refresh',
              ),
              const SizedBox(width: TSizes.sm),
              IconButton(
                onPressed: () {
                  Get.toNamed(AppRoutes.reports);
                },
                icon: const Icon(Iconsax.chart),
                tooltip: 'Reports',
              ),
            ],
          ],
        ),
        floatingActionButton: (!classController.isSelectionMode.value && !classController.isLoading.value)
            ? FloatingActionButton.extended(
                onPressed: () => Get.to(() => CreateClassScreen()),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                icon: const Icon(Iconsax.book_square),
                label: const Text('Create Class'),
                elevation: 4,
              )
            : null,
        body: _buildBody(context),
        bottomNavigationBar: classController.isSelectionMode.value ? _buildSelectionActionBar(context) : null,
      );
    });
  }

  Widget _buildBody(BuildContext context) {
    if (classController.isLoading.value) {
      return _buildShimmerLoading(context);
    }

    if (classController.classes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.book_1, size: 64, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text('No Classes Yet', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            Text('Create your first class to get started', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: TSizes.spaceBtwItems),
            ElevatedButton.icon(
              onPressed: () => Get.to(() => CreateClassScreen()),
              icon: const Icon(Iconsax.add),
              label: const Text('Create Class'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => classController.loadClasses(),
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).cardTheme.color ?? Colors.white,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        itemCount: classController.filteredClasses.length + ((classController.hasMoreClasses.value || classController.isLoadingMore.value) ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= classController.filteredClasses.length) {
            return _buildLoadMoreButton();
          }

          final classItem = classController.filteredClasses[index];
          final isSelected = classController.selectedClassIds.contains(classItem.id);

          return _buildClassCard(context, classItem, isSelected);
        },
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlightColor = Theme.of(context).colorScheme.surface.withValues(alpha: 0.5);

    return ListView.builder(
      itemCount: 6,
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Card(
            margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
            child: Container(height: 150, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(TSizes.cardRadiusMd))),
          ),
        );
      },
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwItems),
      child: Center(
        child: classController.isLoadingMore.value
            ? const CircularProgressIndicator()
            : OutlinedButton(onPressed: classController.loadMoreClasses, child: const Text('Load More')),
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, ClassModel classItem, bool isSelected) {
    return GestureDetector(
      onLongPress: () {
        if (!classController.isSelectionMode.value) {
          classController.toggleSelectionMode(classItem.id);
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
        elevation: isSelected ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          side: BorderSide(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            if (classController.isSelectionMode.value) {
              classController.toggleClassSelection(classItem.id);
            }
          },
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          child: Padding(
            padding: const EdgeInsets.all(TSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        classItem.subjectName?.substring(0, 1) ?? 'C',
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(classItem.subjectName ?? 'Unknown Subject', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text('${classItem.courseName} - Semester ${classItem.semester}', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    if (!classController.isSelectionMode.value)
                      IconButton(
                        icon: const Icon(Iconsax.more),
                        onPressed: () => _showClassOptions(context, classItem),
                      ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                const Divider(),
                if (!classController.isSelectionMode.value)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        context,
                        icon: Iconsax.people,
                        label: 'Students',
                        onTap: () => Get.to(() => AddStudentScreen(classModel: classItem)),
                      ),
                      _buildActionButton(
                        context,
                        icon: Iconsax.calendar_1,
                        label: 'Attendance',
                        onTap: () => Get.to(() => AttendanceScreen(classModel: classItem)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionActionBar(BuildContext context) {
    return BottomAppBar(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${classController.selectedClassIds.length} Selected', style: Theme.of(context).textTheme.titleMedium),
            ElevatedButton.icon(
              onPressed: classController.selectedClassIds.isEmpty ? null : () => _showDeleteSelectedConfirmation(context),
              icon: const Icon(Iconsax.trash, size: 18),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, elevation: 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: TSizes.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showClassOptions(BuildContext context, ClassModel classItem) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(TSizes.cardRadiusLg))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(context).colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)), margin: const EdgeInsets.only(bottom: 20)),
              Text('Class Options', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: TSizes.spaceBtwItems),
              ListTile(
                leading: Icon(Iconsax.edit, color: Theme.of(context).colorScheme.primary),
                title: const Text('Edit Class'),
                onTap: () {
                  Get.back();
                  _showEditClassDialog(context, classItem);
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.trash, color: Colors.red),
                title: const Text('Delete Class', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Get.back();
                  _showDeleteConfirmation(context, classItem);
                },
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, ClassModel classItem) {
    Get.defaultDialog(
      title: 'Delete Class',
      middleText: 'Are you sure you want to delete "${classItem.subjectName}"? This action cannot be undone.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        classController.deleteClass(classItem.id);
      },
    );
  }

  void _showDeleteSelectedConfirmation(BuildContext context) {
    final count = classController.selectedClassIds.length;
    Get.defaultDialog(
      title: 'Delete Selected',
      middleText: 'Are you sure you want to delete $count selected classes? This action cannot be undone.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        classController.deleteSelectedClasses();
      },
    );
  }

  void _showEditClassDialog(BuildContext context, ClassModel classItem) {
    classController.loadClassForEditing(classItem);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Class'),
        content: SingleChildScrollView(
          child: Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<SubjectModel>(
                    decoration: const InputDecoration(labelText: 'Subject'),
                    value: classController.selectedSubject.value,
                    items: classController.subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                    onChanged: (v) {
                      classController.selectedSubject.value = v;
                      if (v != null) classController.selectedSubjectId.value = v.id;
                    },
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  DropdownButtonFormField<dynamic>(
                    decoration: const InputDecoration(labelText: 'Course'),
                    value: classController.selectedCourse.value,
                    items: classController.courses.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                    onChanged: (v) {
                      classController.selectedCourse.value = v;
                      if (v != null) classController.selectedCourseId.value = v.id;
                    },
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  TextFormField(
                    controller: classController.semesterController,
                    decoration: const InputDecoration(labelText: 'Semester'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  TextFormField(
                    controller: classController.sectionController,
                    decoration: const InputDecoration(labelText: 'Section (Optional)'),
                  ),
                ],
              )),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text(TTexts.cancel)),
          ElevatedButton(
            onPressed: () {
              classController.updateClass(classItem.id);
              Get.back();
            },
            child: const Text('Update Class'),
          ),
        ],
      ),
    );
  }
}
