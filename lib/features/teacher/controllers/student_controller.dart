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

  final availableStudents = <StudentModel>[].obs;
  final selectedStudents = <StudentModel>[].obs;
  final isFetchingAvailableStudents = false.obs;
  final sortOption = 'name'.obs;

  final nameController = TextEditingController();
  final rollNumberController = TextEditingController();

  @override
  void onClose() {
    print('Disposing controllers');
    nameController.dispose();
    rollNumberController.dispose();
    super.onClose();
  }

  void setSelectedClass(ClassModel classModel) {
    print('Setting selected class: ${classModel.id}');
    selectedClass.value = classModel;
    loadStudentsForClass(classModel.id);
  }

  Future<void> loadStudentsForClass(String classId) async {
    print('Loading students for class: $classId');
    try {
      isLoading.value = true;
      final classStudents = await studentService.getStudentsForClass(classId);
      print('Loaded students: $classStudents');
      students.assignAll(classStudents);
    } catch (e) {
      print('Error loading students: $e');
      TSnackBar.showError(message: 'Failed to load students: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addStudentToClass() async {
    print('Adding student to class');
    try {
      if (selectedClass.value == null) {
        print('No class selected');
        TSnackBar.showError(message: 'No class selected');
        return;
      }

      isLoading.value = true;

      await studentService.addStudentToClass(
        name: nameController.text.trim(),
        rollNumber: rollNumberController.text.trim(),
        classId: selectedClass.value!.id,
      );

      print('Student added successfully');
      await loadStudentsForClass(selectedClass.value!.id);

      nameController.clear();
      rollNumberController.clear();

      TSnackBar.showSuccess(message: 'Student added successfully');
    } catch (e) {
      print('Error adding student: $e');
      TSnackBar.showError(message: 'Failed to add student: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeStudentFromClass(String studentId) async {
    print('Removing student: $studentId');
    try {
      if (selectedClass.value == null) {
        print('No class selected');
        TSnackBar.showError(message: 'No class selected');
        return;
      }

      isLoading.value = true;

      await studentService.removeStudentFromClass(
        studentId: studentId,
        classId: selectedClass.value!.id,
      );

      students.removeWhere((s) => s.id == studentId);
      print('Student removed successfully');
      TSnackBar.showSuccess(message: 'Student removed successfully');
    } catch (e) {
      print('Error removing student: $e');
      TSnackBar.showError(message: 'Failed to remove student: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAvailableStudents() async {
    print('Fetching available students');
    try {
      if (selectedClass.value == null) {
        print('No class selected');
        TSnackBar.showError(message: 'No class selected');
        return;
      }

      isFetchingAvailableStudents.value = true;
      selectedStudents.clear();

      final allStudents = await studentService.getAllStudents();
      print('All students: $allStudents');

      final currentStudentIds = students.map((s) => s.id).toSet();
      final filteredStudents = allStudents
          .where((student) => !currentStudentIds.contains(student.id))
          .toList();

      print('Filtered students: $filteredStudents');
      filteredStudents.sort((a, b) => a.name.compareTo(b.name));

      availableStudents.assignAll(filteredStudents);
    } catch (e) {
      print('Error fetching available students: $e');
      TSnackBar.showError(
          message: 'Failed to fetch available students: ${e.toString()}');
    } finally {
      isFetchingAvailableStudents.value = false;
    }
  }
  void selectStudent(StudentModel student) {
    print('Selecting student: ${student.id}');
    if (!selectedStudents.any((s) => s.id == student.id)) {
      selectedStudents.add(student);
    }
  }

  void deselectStudent(StudentModel student) {
    print('Deselecting student: ${student.id}');
    selectedStudents.removeWhere((s) => s.id == student.id);
  }

  Future<void> importSelectedStudents() async {
    print('Importing selected students');
    try {
      if (selectedClass.value == null) {
        print('No class selected');
        TSnackBar.showError(message: 'No class selected');
        return;
      }

      if (selectedStudents.isEmpty) {
        print('No students selected for import');
        TSnackBar.showInfo(message: 'No students selected for import');
        return;
      }

      isLoading.value = true;

      for (final student in selectedStudents) {
        print('Importing student: ${student.id}');
        await studentService.addStudentToClass(
          name: student.name,
          rollNumber: student.rollNumber,
          classId: selectedClass.value!.id,
        );
      }

      await loadStudentsForClass(selectedClass.value!.id);

      print('Imported ${selectedStudents.length} students');
      selectedStudents.clear();

      TSnackBar.showSuccess(
          message: 'Successfully imported ${selectedStudents.length} students');
    } catch (e) {
      print('Error importing students: $e');
      TSnackBar.showError(
          message: 'Failed to import students: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  // Add these methods to your StudentController class

// Sort available students with more options
  void sortAvailableStudents(String option) {
    sortOption.value = option;

    switch (option) {
      case 'name':
        availableStudents.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'nameDesc':
        availableStudents.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'rollNumber':
        availableStudents.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));
        break;
      case 'rollNumberDesc':
        availableStudents.sort((a, b) => b.rollNumber.compareTo(a.rollNumber));
        break;
      case 'semester':
        // Sort by semester (extracted from roll number)
        availableStudents.sort((a, b) {
          final semA = _getSemesterFromRollNumber(a.rollNumber);
          final semB = _getSemesterFromRollNumber(b.rollNumber);
          return semA.compareTo(semB);
        });
        break;
    }

    availableStudents.refresh();
  }

// Select all filtered students
  void selectAllFilteredStudents(List<StudentModel> filteredStudents) {
    for (var student in filteredStudents) {
      if (!selectedStudents.any((s) => s.id == student.id)) {
        selectedStudents.add(student);
      }
    }
  }

// Deselect all students
  void deselectAllStudents() {
    selectedStudents.clear();
  }

// Helper method to extract semester from roll number (same as in the dialog)
  int _getSemesterFromRollNumber(String rollNumber) {
    try {
      if (rollNumber.length < 5) return 0;

      final yearPart = rollNumber.substring(3, 5);
      final admissionYear = 2000 + int.parse(yearPart);

      final now = DateTime.now();
      final currentYear = now.year;
      final currentMonth = now.month;

      int yearsSinceAdmission = currentYear - admissionYear;
      int semester = yearsSinceAdmission * 2;

      if (currentMonth >= 7) {
        semester += 1;
      }

      return semester.clamp(1, 6);
    } catch (e) {
      print('Error parsing semester from roll number: $e');
      return 0;
    }
  }
}
