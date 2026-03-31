import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/routes/app_routes.dart';
import '../../../common/utils/constants/colors.dart';
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
      final isSelectionMode = classController.isSelectionMode.value;
      return Scaffold(
        backgroundColor: TColors.slate50,
        appBar: AppBar(
          title: Text(
            (isSelectionMode
                    ? '${classController.selectedClassIds.length} SELECTED'
                    : 'MY CLASSES')
                .toUpperCase(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.0),
          ),
          leading: isSelectionMode
              ? IconButton(
                  onPressed: () => classController.toggleSelectionMode(null),
                  icon: const Icon(Icons.close, color: Color(0xFFE11D48)),
                )
              : null,
          actions: [
            if (isSelectionMode)
              IconButton(
                onPressed: () => classController.toggleSelectAll(),
                icon: Icon(
                  classController.isAllSelected.value
                      ? Icons.select_all
                      : Icons.select_all_outlined,
                  color: TColors.executiveNavy,
                ),
              ),
            if (!isSelectionMode) ...[
              IconButton(
                onPressed: () => classController.loadClasses(),
                icon: const Icon(Iconsax.refresh, color: TColors.slate900),
                tooltip: 'Refresh',
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => Get.toNamed(AppRoutes.reports),
                icon: const Icon(Iconsax.chart, color: TColors.executiveNavy),
                tooltip: 'Reports',
              ),
            ],
          ],
        ),
        floatingActionButton: (!isSelectionMode && !classController.isLoading.value)
            ? FloatingActionButton.extended(
                onPressed: () => Get.to(() => CreateClassScreen()),
                backgroundColor: TColors.executiveNavy,
                foregroundColor: Colors.white,
                icon: const Icon(Iconsax.book_square, size: 20),
                label: const Text('CREATE CLASS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: const BorderSide(color: Colors.white, width: 1.5)),
              )
            : null,
        body: _buildBody(context),
        bottomNavigationBar: isSelectionMode ? _buildSelectionActionBar(context) : null,
      );
    });
  }

  Widget _buildBody(BuildContext context) {
    if (classController.isLoading.value) {
      return _buildShimmerLoading(context);
    }

    if (classController.classes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.book_1, size: 80, color: TColors.slate300),
              const SizedBox(height: 24),
              const Text('NO CLASSES YET', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: TColors.slate900)),
              const SizedBox(height: 8),
              const Text('CREATE YOUR FIRST CLASS TO GET STARTED WITH THE SMARTCAMPUS SYSTEM.', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: TColors.slate600), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Get.to(() => CreateClassScreen()),
                icon: const Icon(Iconsax.add, size: 20),
                label: const Text('CREATE CLASS'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => classController.loadClasses(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
    return ListView.builder(
      itemCount: 4,
      padding: const EdgeInsets.all(24),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: TColors.slate200,
          highlightColor: TColors.white,
          child: Container(
            height: 150, 
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
        );
      },
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: classController.isLoadingMore.value
            ? const CircularProgressIndicator()
            : OutlinedButton(onPressed: classController.loadMoreClasses, child: const Text('LOAD MORE')),
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, ClassModel classItem, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSelected ? TColors.executiveNavy : TColors.slate400, 
          width: isSelected ? 2.5 : 1.5
        ),
      ),
      child: InkWell(
        onLongPress: () {
          if (!classController.isSelectionMode.value) {
            classController.toggleSelectionMode(classItem.id);
          }
        },
        onTap: () {
          if (classController.isSelectionMode.value) {
            classController.toggleClassSelection(classItem.id);
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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: TColors.blue100,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: TColors.executiveNavy, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        (classItem.subjectName?.substring(0, 1) ?? 'C').toUpperCase(),
                        style: const TextStyle(color: TColors.executiveNavy, fontWeight: FontWeight.w900, fontSize: 20),
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
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: TColors.slate900, letterSpacing: -0.5)
                        ),
                        Text(
                          '${classItem.courseName} - SEMESTER ${classItem.semester}'.toUpperCase(), 
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: TColors.slate600, letterSpacing: 0.5)
                        ),
                      ],
                    ),
                  ),
                  if (!classController.isSelectionMode.value)
                    IconButton(
                      icon: const Icon(Iconsax.more, color: TColors.slate900),
                      onPressed: () => _showClassOptions(context, classItem),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(thickness: 1.5),
              if (!classController.isSelectionMode.value)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        context,
                        icon: Iconsax.people,
                        label: 'STUDENTS',
                        onTap: () => Get.to(() => AddStudentScreen(classModel: classItem)),
                      ),
                      Container(width: 1.5, height: 24, color: TColors.slate200),
                      _buildActionButton(
                        context,
                        icon: Iconsax.calendar_1,
                        label: 'ATTENDANCE',
                        onTap: () => Get.to(() => AttendanceScreen(classModel: classItem)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionActionBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TColors.white,
        border: Border(top: BorderSide(color: TColors.executiveNavy, width: 3.0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${classController.selectedClassIds.length} SELECTED', 
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: TColors.slate900)
          ),
          ElevatedButton.icon(
            onPressed: classController.selectedClassIds.isEmpty ? null : () => _showDeleteSelectedConfirmation(context),
            icon: const Icon(Iconsax.trash, size: 18),
            label: const Text('DELETE'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: TColors.executiveNavy),
            const SizedBox(width: 8),
            Text(
              label, 
              style: const TextStyle(color: TColors.executiveNavy, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)
            ),
          ],
        ),
      ),
    );
  }

  void _showClassOptions(BuildContext context, ClassModel classItem) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: TColors.white, 
          borderRadius: BorderRadius.zero,
          border: Border(top: BorderSide(color: TColors.executiveNavy, width: 3.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('CLASS OPTIONS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
            const SizedBox(height: 24),
            _buildOptionTile(
              label: 'EDIT CLASS', 
              icon: Iconsax.edit, 
              color: TColors.executiveNavy,
              onTap: () {
                Get.back();
                _showEditClassDialog(context, classItem);
              }
            ),
            _buildOptionTile(
              label: 'DELETE CLASS', 
              icon: Iconsax.trash, 
              color: const Color(0xFFE11D48),
              onTap: () {
                Get.back();
                _showDeleteConfirmation(context, classItem);
              }
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: TColors.slate300, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14)),
        onTap: onTap,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ClassModel classItem) {
    _showCorporateDialog(
      context,
      title: 'DELETE CLASS',
      message: 'ARE YOU SURE YOU WANT TO DELETE "${classItem.subjectName.toString().toUpperCase()}"? THIS ACTION CANNOT BE UNDONE.',
      confirmLabel: 'DELETE',
      onConfirm: () {
        Get.back();
        classController.deleteClass(classItem.id);
      },
      isDestructive: true,
    );
  }

  void _showDeleteSelectedConfirmation(BuildContext context) {
    final count = classController.selectedClassIds.length;
    _showCorporateDialog(
      context,
      title: 'DELETE SELECTED',
      message: 'ARE YOU SURE YOU WANT TO DELETE $count SELECTED CLASSES? THIS ACTION CANNOT BE UNDONE.',
      confirmLabel: 'DELETE',
      onConfirm: () {
        Get.back();
        classController.deleteSelectedClasses();
      },
      isDestructive: true,
    );
  }

  void _showCorporateDialog(BuildContext context, {required String title, required String message, required String confirmLabel, required VoidCallback onConfirm, bool isDestructive = false}) {
    Get.dialog(
      AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: TColors.executiveNavy, width: 2.0)),
        backgroundColor: TColors.white,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: TColors.slate600)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('CANCEL', style: TextStyle(color: TColors.slate600, fontWeight: FontWeight.w900))),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(backgroundColor: isDestructive ? const Color(0xFFE11D48) : TColors.executiveNavy),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  void _showEditClassDialog(BuildContext context, ClassModel classItem) {
    classController.loadClassForEditing(classItem);
    Get.dialog(
      AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: TColors.executiveNavy, width: 2.0)),
        backgroundColor: TColors.white,
        title: const Text('EDIT CLASS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        content: SingleChildScrollView(
          child: Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<SubjectModel>(
                    decoration: const InputDecoration(labelText: 'SUBJECT'),
                    value: classController.selectedSubject.value,
                    items: classController.subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase()))).toList(),
                    onChanged: (v) {
                      classController.selectedSubject.value = v;
                      if (v != null) classController.selectedSubjectId.value = v.id;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<dynamic>(
                    decoration: const InputDecoration(labelText: 'COURSE'),
                    value: classController.selectedCourse.value,
                    items: classController.courses.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toString().toUpperCase()))).toList(),
                    onChanged: (v) {
                      classController.selectedCourse.value = v;
                      if (v != null) classController.selectedCourseId.value = v.id;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: classController.semesterController,
                    decoration: const InputDecoration(labelText: 'SEMESTER'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: classController.sectionController,
                    decoration: const InputDecoration(labelText: 'SECTION (OPTIONAL)'),
                  ),
                ],
              )),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('CANCEL', style: TextStyle(color: TColors.slate600, fontWeight: FontWeight.w900))),
          ElevatedButton(
            onPressed: () {
              classController.updateClass(classItem.id);
              Get.back();
            },
            child: const Text('UPDATE CLASS'),
          ),
        ],
      ),
    );
  }
}
