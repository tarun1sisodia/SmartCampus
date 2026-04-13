import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import '../../../models/class_model.dart';
import '../../../models/student_model.dart';

class StudentDetailController extends GetxController {
  // Removed AttendanceService, ClassService, and StudentService dependencies

  final isLoading = false.obs;
  final student = Rxn<StudentModel>();
  final classModel = Rxn<ClassModel>();
  final attendanceHistory = <Map<String, dynamic>>[].obs;

  // Statistics
  final totalSessions = 0.obs;
  final presentCount = 0.obs;
  final absentCount = 0.obs;
  final lateCount = 0.obs;
  final attendancePercentage = 0.0.obs;

  // Image related variables
  final selectedImage = Rxn<File>();
  final isImageUploading = false.obs;
  final imagePicker = ImagePicker();

  // Set student and class data
  void setStudentAndClass(StudentModel studentModel, String classId) {
    ///print('Setting student and class: studentModel=${studentModel.toJson()}, classId=$classId');
    student.value = studentModel;
    loadStudentData(studentModel.id, classId);
  }

  // Load student data
  Future<void> loadStudentData([String? studentId, String? classId]) async {
    try {
      isLoading.value = true;
      final studentIdToUse = studentId ?? student.value?.id;
      if (studentIdToUse == null) return;

      final response = await ApiClient.dio.get('/attendance/student/$studentIdToUse');
      final data = response.data['data'];
      
      totalSessions.value = data['totalSessions'] ?? 0;
      presentCount.value = data['presentCount'] ?? 0;
      absentCount.value = data['absentCount'] ?? 0;
      lateCount.value = data['lateCount'] ?? 0;
      attendancePercentage.value = (data['attendancePercentage'] ?? 0.0).toDouble();
      
      // Assume historical records are included or fetch separately
      attendanceHistory.assignAll(List<Map<String, dynamic>>.from(data['history'] ?? []));
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      TSnackBar.showError(message: 'Failed to load student data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Method to pick image from gallery or camera
  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await imagePicker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);

        ///print('Image selected: ${pickedFile.path}');
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      ///print('Error picking image: $e');
      TSnackBar.showError(message: 'Failed to pick image: ${e.toString()}');
    }
  }

// Method to delete student image
  Future<void> deleteStudentImage() async {
    try {
      if (student.value == null || student.value!.imageUrl == null) {
        ///print('No image to delete or student information is missing');
        TSnackBar.showError(
            message: 'No image to delete or student information is missing');
        return;
      }

      isImageUploading.value = true;

      await studentService.deleteStudentImage(
        studentId: student.value!.id,
        imageUrl: student.value!.imageUrl!,
      );

      // the student model with null image URL
      student.value = StudentModel(
        id: student.value!.id,
        name: student.value!.name,
        rollNumber: student.value!.rollNumber,
        classId: student.value!.classId,
        imageUrl: null,
        createdAt: student.value!.createdAt,
        updatedAt: DateTime.now(),
        attendanceStatus: student.value!.attendanceStatus,
      );

      TSnackBar.showSuccess(message: 'Student image removed successfully');
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      ///print('Error deleting student image: ${e.toString()}');
      TSnackBar.showError(
          message: 'Failed to delete student image: ${e.toString()}');
    } finally {
      isImageUploading.value = false;
    }
  }

  // Method to update student image
  Future<void> updateStudentImage() async {
    try {
      if (selectedImage.value == null || student.value == null) return;
      isImageUploading.value = true;

      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(selectedImage.value!.path, filename: 'student.jpg'),
      });

      await ApiClient.dio.post('/students/${student.value!.id}/photo', data: formData);
      await loadStudentData();
      TSnackBar.showSuccess(message: 'Student image updated successfully');
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      TSnackBar.showError(message: 'Upload failed: $e');
    } finally {
      isImageUploading.value = false;
    }
  }

  // attendance record
  Future<void> updateAttendanceRecord({
    required String sessionId,
    required String status,
    String? remarks,
  }) async {
    ///print('Updating attendance record: sessionId=$sessionId, status=$status, remarks=$remarks');
    try {
      isLoading.value = true;

      if (student.value == null) {
        ///print('Error: Student information is missing');
        TSnackBar.showError(message: 'Student information is missing');
        return;
      }

      await attendanceService.submitAttendance(
        sessionId: sessionId,
        studentId: student.value!.id,
        status: status,
        remarks: remarks,
      );

      ///print('Attendance record updated successfully');

      // Reload data to reflect changes
      await loadStudentData();

      TSnackBar.showSuccess(message: 'Attendance updated successfully');
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      ///print('Error updating attendance: ${e.toString()}');
      TSnackBar.showError(
          message: 'Failed to update attendance: ${e.toString()}');
    } finally {
      isLoading.value = false;

      ///print('Finished updating attendance record');
    }
  }
}
