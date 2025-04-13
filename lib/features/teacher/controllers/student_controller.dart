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

  // Add these new properties for student import functionality
  final availableStudents = <StudentModel>[].obs;
  final selectedStudents = <StudentModel>[].obs;
  final isFetchingAvailableStudents = false.obs;
  final sortOption = 'name'.obs;

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

  // Fetch available students from Supabase that aren't already in this class
  Future<void> fetchAvailableStudents() async {
    try {
      if (selectedClass.value == null) {
        TSnackBar.showError(message: 'No class selected');
        return;
      }

      isFetchingAvailableStudents.value = true;
      selectedStudents.clear();

      // Get all students from Supabase
      final allStudents = await studentService.getAllStudents();

      // Filter out students that are already in this class
      final currentStudentIds = students.map((s) => s.id).toSet();
      final filteredStudents = allStudents
          .where((student) => !currentStudentIds.contains(student.id))
          .toList();

      // Sort students by name initially
      filteredStudents.sort((a, b) => a.name.compareTo(b.name));

      availableStudents.assignAll(filteredStudents);
    } catch (e) {
      TSnackBar.showError(
          message: 'Failed to fetch available students: ${e.toString()}');
    } finally {
      isFetchingAvailableStudents.value = false;
    }
  }

  // Sort available students by the selected option
  void sortAvailableStudents(String option) {
    sortOption.value = option;

    if (option == 'name') {
      availableStudents.sort((a, b) => a.name.compareTo(b.name));
    } else if (option == 'rollNumber') {
      availableStudents.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));
    }
  }

  // Select a student for import// Select a student for import
  void selectStudent(StudentModel student) {
    // Check if the student is already selected by ID to avoid duplicates
    if (!selectedStudents.any((s) => s.id == student.id)) {
      selectedStudents.add(student);
    }
  }

// Deselect a student
  void deselectStudent(StudentModel student) {
    // Remove by ID comparison
    selectedStudents.removeWhere((s) => s.id == student.id);
  }


  // Import selected students to the current class
  Future<void> importSelectedStudents() async {
    try {
      if (selectedClass.value == null) {
        TSnackBar.showError(message: 'No class selected');
        return;
      }

      if (selectedStudents.isEmpty) {
        TSnackBar.showInfo(message: 'No students selected for import');
        return;
      }

      isLoading.value = true;

      // Add each selected student to the class
      for (final student in selectedStudents) {
        await studentService.addStudentToClass(
          name: student.name,
          rollNumber: student.rollNumber,
          classId: selectedClass.value!.id,
        );
      }

      // Reload students after adding
      await loadStudentsForClass(selectedClass.value!.id);

      // Clear selections
      selectedStudents.clear();

      TSnackBar.showSuccess(
          message: 'Successfully imported ${selectedStudents.length} students');
    } catch (e) {
      TSnackBar.showError(
          message: 'Failed to import students: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
