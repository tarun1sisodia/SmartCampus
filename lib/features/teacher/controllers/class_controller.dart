import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/class_model.dart';
import '../../../models/course_model.dart';
import '../../../models/subject_model.dart';
// Ensure Course is imported
import '../../../services/class_service.dart';
import '../../../services/course_service.dart';
import '../../../services/subject_service.dart';
import '../../../utils/helpers/snackbar_helper.dart';

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
  final yearController = TextEditingController();
  final sectionController = TextEditingController();
  // Define selectedCourse as an observable variable
  var selectedCourse = Rxn<CourseModel>();
  // Add the selectedSubject property
  var selectedSubject = Rxn<dynamic>();

  @override
  void onInit() {
    super.onInit();
    loadClasses();
    loadCoursesAndSubjects();
  }

  @override
  void onClose() {
    yearController.dispose();
    sectionController.dispose();
    super.onClose();
  }

  // Load all classes for the current teacher
  Future<void> loadClasses() async {
    try {
      isLoading.value = true;

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        TSnackBar.showError(message: 'You must be logged in to view classes');
        return;
      }

      final teacherClasses = await classService.getTeacherClasses(
        currentUser.id,
      );

      classes.assignAll(teacherClasses);
    } catch (e) {
      TSnackBar.showError(message: 'Failed to load classes: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Load courses and subjects for dropdowns
  Future<void> loadCoursesAndSubjects() async {
    try {
      isLoading.value = true;

      final allCourses = await courseService.getAllCourses();
      final allSubjects = await subjectService.getAllSubjects();

      courses.assignAll(allCourses);
      subjects.assignAll(allSubjects);

      // Set default selections if available
      if (courses.isNotEmpty) {
        selectedCourseId.value = courses[0].id;
      }

      if (subjects.isNotEmpty) {
        selectedSubjectId.value = subjects[0].id;
      }
    } catch (e) {
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
      if (selectedSubjectId.value.isEmpty ||
          selectedCourseId.value.isEmpty ||
          yearController.text.trim().isEmpty) {
        TSnackBar.showError(message: 'Please fill in all required fields');
        return;
      }

      isLoading.value = true;

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        TSnackBar.showError(message: 'You must be logged in to create a class');
        return;
      }

      final newClass = await classService.createClass(
        teacherId: currentUser.id,
        subjectId: selectedSubjectId.value,
        courseId: selectedCourseId.value,
        year: int.parse(yearController.text.trim()),
        section:
            sectionController.text.trim().isNotEmpty
                ? sectionController.text.trim()
                : null,
      );

      // Add to the list
      classes.insert(0, newClass);

      // Reset form
      yearController.clear();
      sectionController.clear();

      TSnackBar.showSuccess(message: 'Class created successfully');
    } catch (e) {
      TSnackBar.showError(message: 'Failed to create class: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Update an existing class
  Future<void> updateClass(String classId) async {
    try {
      if (selectedSubjectId.value.isEmpty ||
          selectedCourseId.value.isEmpty ||
          yearController.text.trim().isEmpty) {
        TSnackBar.showError(message: 'Please fill in all required fields');
        return;
      }

      isLoading.value = true;

      final updatedClass = await classService.updateClass(
        id: classId,
        subjectId: selectedSubjectId.value,
        courseId: selectedCourseId.value,
        year: int.parse(yearController.text.trim()),
        section:
            sectionController.text.trim().isNotEmpty
                ? sectionController.text.trim()
                : null,
      );

      // Update in the list
      final index = classes.indexWhere((c) => c.id == classId);
      if (index != -1) {
        classes[index] = updatedClass;
        classes.refresh();
      }

      TSnackBar.showSuccess(message: 'Class updated successfully');
    } catch (e) {
      TSnackBar.showError(message: 'Failed to update class: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a class
  Future<void> deleteClass(String classId) async {
    try {
      isLoading.value = true;

      await classService.deleteClass(classId);

      // Remove from the list
      classes.removeWhere((c) => c.id == classId);

      TSnackBar.showSuccess(message: 'Class deleted successfully');
    } catch (e) {
      TSnackBar.showError(message: 'Failed to delete class: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Method to validate the class form
  bool validateClassForm() {
    if (selectedSubjectId.value.isEmpty ||
        selectedCourseId.value.isEmpty ||
        yearController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all required fields.');
      return false;
    }
    return true;
  }

  // Load a class for editing
  void loadClassForEditing(ClassModel classModel) {
    selectedSubjectId.value = classModel.subjectId;
    selectedCourseId.value = classModel.courseId;
    yearController.text = classModel.year.toString();
    sectionController.text = classModel.section ?? '';
  }
}
