import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/class_model.dart';
import '../../../models/student_model.dart';
import '../../../services/student_service.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';

class StudentController extends GetxController {
  final studentService = StudentService();

  final isLoading = false.obs;
  final selectedClass = Rxn<ClassModel>();
  final students = <StudentModel>[].obs;

  // Form controllers
  final nameController = TextEditingController();
  final rollNumberController = TextEditingController();

  @override
  void onClose() {
    nameController.dispose();
    rollNumberController.dispose();
    super.onClose();
  }

  // Set the selected class and load its students
  void setSelectedClass(ClassModel classModel) {
    selectedClass.value = classModel;
    loadStudentsForClass(classModel.id);
  }

  // Load students for a class
  Future<void> loadStudentsForClass(String classId) async {
    try {
      isLoading.value = true;

      final classStudents = await studentService.getStudentsForClass(classId);

      students.assignAll(classStudents);
    } catch (e) {
      TSnackBar.showError(message: 'Failed to load students: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Add a student to the class
  // Update the addStudentToClass method to match the service implementation
  Future<void> addStudentToClass() async {
    try {
      if (selectedClass.value == null) {
        TSnackBar.showError(message: 'No class selected');
        return;
      }

      isLoading.value = true;

      await studentService.addStudentToClass(
        name: nameController.text.trim(),
        rollNumber: rollNumberController.text.trim(),
        classId: selectedClass.value!.id,
      );

      // Reload students after adding
      await loadStudentsForClass(selectedClass.value!.id);

      // Reset form
      nameController.clear();
      rollNumberController.clear();

      TSnackBar.showSuccess(message: 'Student added successfully');
    } catch (e) {
      TSnackBar.showError(message: 'Failed to add student: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Remove a student from the class
  Future<void> removeStudentFromClass(String studentId) async {
    try {
      if (selectedClass.value == null) {
        TSnackBar.showError(message: 'No class selected');
        return;
      }

      isLoading.value = true;

      await studentService.removeStudentFromClass(
        studentId: studentId,
        classId: selectedClass.value!.id,
      );

      // Remove from the list
      students.removeWhere((s) => s.id == studentId);

      TSnackBar.showSuccess(message: 'Student removed successfully');
    } catch (e) {
      TSnackBar.showError(message: 'Failed to remove student: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
