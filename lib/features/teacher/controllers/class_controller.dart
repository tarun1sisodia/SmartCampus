import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/class_model.dart';
import '../../../models/course_model.dart';
import '../../../models/subject_model.dart';
import '../../../services/class_service.dart';
import '../../../services/course_service.dart';
import '../../../services/subject_service.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';

class ClassController extends GetxController {
  final classService = ClassService();
  final courseService = CourseService();
  final subjectService = SubjectService();

  final isLoading = false.obs;
  final classes = <ClassModel>[].obs;
  final courses = <CourseModel>[].obs;
  final subjects = <SubjectModel>[].obs;

  // Form controllers
  final selectedSubjectId = ''.obs;
  final selectedCourseId = ''.obs;
  final semesterController = TextEditingController();
  final sectionController = TextEditingController();
  var selectedCourse = Rxn<CourseModel>();
  var selectedSubject = Rxn<dynamic>();

  // New properties for multi-select
  final isSelectionMode = false.obs;
  final selectedClassIds = <String>{}.obs;
  final isAllSelected = false.obs;

  @override
  void onInit() {
    super.onInit();
    //printnt('ClassController initialized');
    loadClasses();
    loadCoursesAndSubjects();
  }

  @override
  void onClose() {
    //printnt('ClassController disposed');
    semesterController.dispose();
    sectionController.dispose();
    super.onClose();
  }

  // Load all classes for the current teacher
  Future<void> loadClasses() async {
    try {
      //printnt('Loading classes...');
      isLoading.value = true;

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        //printnt('No user logged in');
        TSnackBar.showError(message: 'You must be logged in to view classes');
        return;
      }

      final teacherClasses = await classService.getTeacherClasses(
        currentUser.id,
      );

      //printnt('Classes loaded: $teacherClasses');
      classes.assignAll(teacherClasses);
    } catch (e) {
      //printnt('Error loading classes: $e');
      TSnackBar.showError(message: 'Failed to load classes: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Load courses and subjects for dropdowns
  Future<void> loadCoursesAndSubjects() async {
    try {
      //printnt('Loading courses and subjects...');
      isLoading.value = true;

      final allCourses = await courseService.getAllCourses();
      final allSubjects = await subjectService.getAllSubjects();

      //printnt('Courses loaded: $allCourses');
      //printnt('Subjects loaded: $allSubjects');

      courses.assignAll(allCourses);
      subjects.assignAll(allSubjects);

      // Set default selections if available
      if (courses.isNotEmpty) {
        selectedCourseId.value = courses[0].id;
        //printnt('Default course selected: ${courses[0]}');
      }

      if (subjects.isNotEmpty) {
        selectedSubjectId.value = subjects[0].id;
        //printnt('Default subject selected: ${subjects[0]}');
      }
    } catch (e) {
      //printnt('Error loading courses and subjects: $e');
      TSnackBar.showError(
        message: 'Failed to load courses and subjects: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Create a new class
  Future<void> createClass() async {
    try {
      //printnt('Creating class...');
      if (selectedSubject.value == null ||
          selectedCourse.value == null ||
          semesterController.text.trim().isEmpty) {
        //printnt('Validation Failed');
        TSnackBar.showError(message: 'Please fill in all required fields');
        return;
      }
      //printnt('Validation Passed');
      isLoading.value = true;

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        //printnt('User not logged in');
        TSnackBar.showError(message: 'You must be logged in to create a class');
        return;
      }

      // Check for existing class with same parameters (case-insensitive for section)
      final semester = int.parse(semesterController.text.trim());
      final section = sectionController.text.trim().isNotEmpty
          ? sectionController.text.trim()
          : null;

      // Check if a similar class already exists
      bool duplicateExists = false;
      for (var existingClass in classes) {
        if (existingClass.courseId == selectedCourse.value!.id &&
            existingClass.subjectId == selectedSubject.value.id &&
            existingClass.semester == semester &&
            (section == null && existingClass.section == null ||
                section != null &&
                    existingClass.section != null &&
                    existingClass.section!.toLowerCase() ==
                        section.toLowerCase())) {
          duplicateExists = true;
          break;
        }
      }

      if (duplicateExists) {
        TSnackBar.showError(
          message:
              'A class with these details already exists. Please check the section name.',
          title: 'Duplicate Class',
        );
        isLoading.value = false;
        return;
      }

      //printnt('Creating Class ...');

      final newClass = await classService.createClass(
        teacherId: currentUser.id,
        subjectId: selectedSubject.value.id,
        courseId: selectedCourse.value!.id,
        semester: semester,
        section: section,
      );
      //printnt('Class created: $newClass');
      // Add to the list
      classes.insert(0, newClass);

      // Reset form
      semesterController.clear();
      sectionController.clear();

      TSnackBar.showSuccess(message: 'Class created successfully');
    } catch (e) {
      //printnt('Failed to create class: $e');
      TSnackBar.showError(message: 'Failed to create class: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Update an existing class
  Future<void> updateClass(String classId) async {
    try {
      //printnt('Updating class with ID: $classId');
      if (selectedSubjectId.value.isEmpty ||
          selectedCourseId.value.isEmpty ||
          semesterController.text.trim().isEmpty) {
        //printnt('Validation Failed');
        TSnackBar.showError(message: 'Please fill in all required fields');
        return;
      }

      isLoading.value = true;

      final updatedClass = await classService.updateClass(
        classId: classId,
        subjectId: selectedSubjectId.value,
        courseId: selectedCourseId.value,
        semester: int.parse(semesterController.text.trim()),
        section: sectionController.text.trim().isNotEmpty
            ? sectionController.text.trim()
            : null,
      );

      //printnt('Class updated: $updatedClass');

      // Update in the list
      final index = classes.indexWhere((c) => c.id == classId);
      if (index != -1) {
        classes[index] = updatedClass;
        classes.refresh();
      }

      TSnackBar.showSuccess(message: 'Class updated successfully');
    } catch (e) {
      //printnt('Failed to update class: $e');
      TSnackBar.showError(message: 'Failed to update class: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a class
  Future<void> deleteClass(String classId) async {
    try {
      //printnt('Deleting class with ID: $classId');
      isLoading.value = true;

      // First delete related records (like students, attendance, etc.)
      await Supabase.instance.client
          .from('class_students')
          .delete()
          .eq('class_id', classId);

      // Then delete the class itself
      await Supabase.instance.client.from('classes').delete().eq('id', classId);

      // Remove the class from the local list
      classes.removeWhere((c) => c.id == classId);

      //printnt('Class deleted successfully');
      TSnackBar.showSuccess(message: 'Class deleted successfully');
    } catch (e) {
      //printnt('Failed to delete class: $e');
      TSnackBar.showError(message: 'Failed to delete class: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Method to validate the class form
  bool validateClassForm() {
    //printnt('Validating class form...');
    if (selectedSubjectId.value.isEmpty ||
        selectedCourseId.value.isEmpty ||
        semesterController.text.isEmpty) {
      //printnt('Validation Failed');
      Get.snackbar('Error', 'Please fill in all required fields.');
      return false;
    }
    //printnt('Validation Passed');
    return true;
  }

  // Load a class for editing
  void loadClassForEditing(ClassModel classModel) {
    //printnt('Loading class for editing: $classModel');
    selectedSubjectId.value = classModel.subjectId;
    selectedCourseId.value = classModel.courseId;
    semesterController.text = classModel.semester.toString();
    sectionController.text = classModel.section ?? '';
  }

  // New methods for multi-select functionality

  void toggleSelectionMode(String? initialClassId) {
    isSelectionMode.value = !isSelectionMode.value;

    if (!isSelectionMode.value) {
      // Clear selections when exiting selection mode
      clearSelections();
    } else if (initialClassId != null) {
      // If entering selection mode with an initial selection
      selectedClassIds.add(initialClassId);
    }
  }

  void toggleClassSelection(String classId) {
    if (selectedClassIds.contains(classId)) {
      selectedClassIds.remove(classId);
      // If no classes are selected, exit selection mode
      if (selectedClassIds.isEmpty) {
        isSelectionMode.value = false;
      }
    } else {
      selectedClassIds.add(classId);
    }

    // Update "all selected" state
    isAllSelected.value = selectedClassIds.length == classes.length;
  }

  void toggleSelectAll() {
    if (isAllSelected.value) {
      // Deselect all
      selectedClassIds.clear();
      isSelectionMode.value = false;
    } else {
      // Select all
      selectedClassIds.clear();
      for (var classItem in classes) {
        selectedClassIds.add(classItem.id);
      }
    }
    isAllSelected.value = !isAllSelected.value;
  }

  void clearSelections() {
    selectedClassIds.clear();
    isAllSelected.value = false;
  }

  Future<void> deleteSelectedClasses() async {
    try {
      isLoading.value = true;

      // Create a copy to avoid modification during iteration
      final classesToDelete = Set<String>.from(selectedClassIds);

      for (var classId in classesToDelete) {
        await deleteClass(classId);
      }

      // Exit selection mode
      isSelectionMode.value = false;
      clearSelections();

      // Show success message
      final count = classesToDelete.length;
      TSnackBar.showSuccess(
        message:
            '$count ${count == 1 ? 'class' : 'classes'} deleted successfully',
        title: 'Success',
      );
    } catch (e) {
      //printnt('Error deleting selected classes: $e');
      TSnackBar.showError(message: 'Failed to delete classes: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
