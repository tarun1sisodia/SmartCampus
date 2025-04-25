import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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

  final selectedImage = Rxn<File>();
  final isImageUploading = false.obs;
  final imagePicker = ImagePicker();

  final isSelectionMode = false.obs;
  final selectedStudentIds = <String>{}.obs;
  final isAllSelected = false.obs;

  @override
  void onClose() {
    //printnt('Disposing controllers');
    nameController.dispose();
    rollNumberController.dispose();
    super.onClose();
  }

  void setSelectedClass(ClassModel classModel) {
    //printnt('Setting selected class: ${classModel.id}');
    selectedClass.value = classModel;
    loadStudentsForClass(classModel.id);
  }

  Future<void> loadStudentsForClass(String classId) async {
    //printnt('Loading students for class: $classId');
    try {
      isLoading.value = true;
      final classStudents = await studentService.getStudentsForClass(classId);
      //printnt('Loaded students: $classStudents');
      students.assignAll(classStudents);
    } catch (e) {
      //printnt('Error loading students: $e');
      TSnackBar.showError(message: 'Failed to load students: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Method to pick image from gallery or camera
  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await imagePicker.pickImage(
        source: source,
        imageQuality: 70, // Reduce image quality to save storage
        maxWidth: 800, // Limit image dimensions
        maxHeight: 800,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
        //printnt('Image selected: ${pickedFile.path}');
      }
    } catch (e) {
      //printnt('Error picking image: $e');
      TSnackBar.showError(message: 'Failed to pick image: ${e.toString()}');
    }
  }

  // Method to clear selected image
  void clearSelectedImage() {
    selectedImage.value = null;
  }

  // Update addStudentToClass method to include image
  Future<void> addStudentToClass() async {
    //printnt('Adding student to class');
    try {
      if (selectedClass.value == null) {
        //printnt('No class selected');
        TSnackBar.showError(message: 'No class selected');
        return;
      }

      isLoading.value = true;

      await studentService.addStudentToClass(
        name: nameController.text.trim(),
        rollNumber: rollNumberController.text.trim(),
        classId: selectedClass.value!.id,
        imageFile: selectedImage.value, // Pass the selected image
      );

      //printnt('Student added successfully');
      await loadStudentsForClass(selectedClass.value!.id);

      nameController.clear();
      rollNumberController.clear();
      clearSelectedImage(); // Clear the selected image

      TSnackBar.showSuccess(message: 'Student added successfully');
    } catch (e) {
      //printnt('Error adding student: $e');
      TSnackBar.showError(message: 'Failed to add student: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle selection mode
  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      // Clear selections when exiting selection mode
      selectedStudentIds.clear();
      isAllSelected.value = false;
    }
  }

// Toggle selection of a student
  void toggleStudentSelection(String studentId) {
    if (selectedStudentIds.contains(studentId)) {
      selectedStudentIds.remove(studentId);
    } else {
      selectedStudentIds.add(studentId);
    }

    // Update "all selected" state
    isAllSelected.value = selectedStudentIds.length == students.length;
    // Force UI refresh
    students.refresh();
  }

// Toggle select all students
  void toggleSelectAll() {
    if (isAllSelected.value) {
      // Deselect all
      selectedStudentIds.clear();
    } else {
      // Select all
      selectedStudentIds.clear();
      for (var student in students) {
        selectedStudentIds.add(student.id);
      }
    }
    isAllSelected.value = !isAllSelected.value;
    // Force UI refresh
    students.refresh();
  }

// Remove selected students from class
  Future<void> removeSelectedStudentsFromClass() async {
    try {
      isLoading.value = true;

      // Create a copy to avoid modification during iteration
      final studentsToRemove = Set<String>.from(selectedStudentIds);

      for (var studentId in studentsToRemove) {
        await removeStudentFromClass(studentId, showSnackbar: false);
      }

      // Exit selection mode
      toggleSelectionMode();

      // Show success message
      final count = studentsToRemove.length;
      TSnackBar.showSuccess(
        message:
            '$count ${count == 1 ? 'student' : 'students'} removed successfully',
        title: 'Success',
      );
    } catch (e) {
      //printnt('Error removing selected students: $e');
      TSnackBar.showError(
          message: 'Failed to remove students: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Method to update student image
  Future<void> updateStudentImage(String studentId, String rollNumber) async {
    try {
      if (selectedImage.value == null) {
        //printnt('No image selected');
        TSnackBar.showError(message: 'No image selected');
        return;
      }

      isImageUploading.value = true;

      final imageUrl = await studentService.updateStudentImage(
        studentId: studentId,
        imageFile: selectedImage.value!,
        rollNumber: rollNumber,
      );

      if (imageUrl != null) {
        // Update the student in the local list
        final index = students.indexWhere((s) => s.id == studentId);
        if (index != -1) {
          final updatedStudent = StudentModel(
            id: students[index].id,
            name: students[index].name,
            rollNumber: students[index].rollNumber,
            classId: students[index].classId,
            imageUrl: imageUrl,
            createdAt: students[index].createdAt,
            updatedAt: DateTime.now(),
          );
          students[index] = updatedStudent;
          students.refresh();
        }

        clearSelectedImage();
        TSnackBar.showSuccess(message: 'Student image updated successfully');
      }
    } catch (e) {
      //printnt('Error updating student image: $e');
      TSnackBar.showError(
          message: 'Failed to update student image: ${e.toString()}');
    } finally {
      isImageUploading.value = false;
    }
  }

  Future<void> removeStudentFromClass(String studentId,
      {bool showSnackbar = true}) async {
    try {
      //printnt('Removing student with ID: $studentId from class');
      isLoading.value = true;

      if (selectedClass.value == null) {
        //printnt('No class selected');
        TSnackBar.showError(message: 'No class selected');
        return;
      }

      await studentService.removeStudentFromClass(
        studentId: studentId,
        classId: selectedClass.value!.id,
      );

      //printnt('Student removed successfully');
      students.removeWhere((student) => student.id == studentId);

      // Only show snackbar if requested (for individual deletions)
      if (showSnackbar) {
        TSnackBar.showSuccess(message: 'Student removed successfully');
      }
    } catch (e) {
      //printnt('Error removing student: $e');
      TSnackBar.showError(message: 'Failed to remove student: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAvailableStudents() async {
    //printnt('Fetching available students');
    try {
      if (selectedClass.value == null) {
        //printnt('No class selected');
        TSnackBar.showError(message: 'No class selected');
        return;
      }

      isFetchingAvailableStudents.value = true;
      selectedStudents.clear();

      final allStudents = await studentService.getAllStudents();
      //printnt('All students: $allStudents');

      final currentStudentIds = students.map((s) => s.id).toSet();
      final filteredStudents = allStudents
          .where((student) => !currentStudentIds.contains(student.id))
          .toList();

      //printnt('Filtered students: $filteredStudents');
      filteredStudents.sort((a, b) => a.name.compareTo(b.name));

      availableStudents.assignAll(filteredStudents);
    } catch (e) {
      //printnt('Error fetching available students: $e');
      TSnackBar.showError(
          message: 'Failed to fetch available students: ${e.toString()}');
    } finally {
      isFetchingAvailableStudents.value = false;
    }
  }

  void selectStudent(StudentModel student) {
    //printnt('Selecting student: ${student.id}');
    if (!selectedStudents.any((s) => s.id == student.id)) {
      selectedStudents.add(student);
    }
  }

  void deselectStudent(StudentModel student) {
    //printnt('Deselecting student: ${student.id}');
    selectedStudents.removeWhere((s) => s.id == student.id);
  }

  Future<void> importSelectedStudents() async {
    //printnt('Importing selected students');
    try {
      if (selectedClass.value == null) {
        //printnt('No class selected');
        TSnackBar.showError(message: 'No class selected');
        return;
      }

      if (selectedStudents.isEmpty) {
        //printnt('No students selected for import');
        TSnackBar.showInfo(message: 'No students selected for import');
        return;
      }

      isLoading.value = true;

      for (final student in selectedStudents) {
        //printnt('Importing student: ${student.id}');
        await studentService.addStudentToClass(
          name: student.name,
          rollNumber: student.rollNumber,
          classId: selectedClass.value!.id,
        );
      }

      await loadStudentsForClass(selectedClass.value!.id);

      //printnt('Imported ${selectedStudents.length} students');
      selectedStudents.clear();

      TSnackBar.showSuccess(
          message: 'Successfully imported ${selectedStudents.length} students');
    } catch (e) {
      //printnt('Error importing students: $e');
      TSnackBar.showError(
          message: 'Failed to import students: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

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
      //printnt('Error parsing semester from roll number: $e');
      return 0;
    }
  }
}
