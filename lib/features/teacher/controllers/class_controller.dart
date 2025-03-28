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
  // Update the createClass method to use the selected subject and course
  Future<void> createClass() async {
    try {
      if (selectedSubject.value == null ||
          selectedCourse.value == null ||
          yearController.text.trim().isEmpty) {
        print('Validation Failed');
        TSnackBar.showError(message: 'Please fill in all required fields');
        return;
      }
      print('Validation Passed');
      isLoading.value = true;

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        print('User not logged in');
        TSnackBar.showError(message: 'You must be logged in to create a class');
        return;
      }
      print('Creating Class ...');

      final newClass = await classService.createClass(
        teacherId: currentUser.id,
        subjectId: selectedSubject.value.id,
        courseId: selectedCourse.value!.id,
        year: int.parse(yearController.text.trim()),
        section:
            sectionController.text.trim().isNotEmpty
                ? sectionController.text.trim()
                : null,
      );
      print('Class created: $newClass');
      // Add to the list
      classes.insert(0, newClass);

      // Reset form
      yearController.clear();
      sectionController.clear();

      TSnackBar.showSuccess(message: 'Class created successfully');
    } catch (e) {
      print('Failed to create class: $e');
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
        classId: classId,
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
  // Delete a class
  Future<void> deleteClass(String classId) async {
    try {
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

      TSnackBar.showSuccess(message: 'Class deleted successfully');
    } catch (e) {
      TSnackBar.showError(message: 'Failed to delete class: ${e.toString()}');
      // Don't rethrow the exception since we're already handling it with the snackbar
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
