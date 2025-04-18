import 'package:attedance__/models/class_model.dart';
import 'package:attedance__/models/student_model.dart';
import 'package:attedance__/services/attendance_service.dart';
import 'package:attedance__/services/class_service.dart';
import 'package:attedance__/common/utils/helpers/snackbar_helper.dart';
import 'package:get/get.dart';

class StudentDetailController extends GetxController {
  final attendanceService = AttendanceService();
  final classService = ClassService();
  
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
  
  // Set student and class data
  void setStudentAndClass(StudentModel studentModel, String classId) {
    print('Setting student and class: studentModel=${studentModel.toJson()}, classId=$classId');
    student.value = studentModel;
    loadStudentData(studentModel.id, classId);
  }
  
  // Load student data
  Future<void> loadStudentData([String? studentId, String? classId]) async {
    print('Loading student data: studentId=$studentId, classId=$classId');
    try {
      isLoading.value = true;
      
      final studentIdToUse = studentId ?? student.value?.id;
      final classIdToUse = classId ?? classModel.value?.id;
      
      if (studentIdToUse == null || classIdToUse == null) {
        print('Error: Student or class information is missing');
        TSnackBar.showError(message: 'Student or class information is missing');
        return;
      }
      
      // Load class details
      print('Fetching class details for classId=$classIdToUse');
      final classDetails = await classService.getClassById(classIdToUse);
      classModel.value = classDetails;
      print('Class details loaded: ${classDetails.toJson()}');
      
      // Load attendance statistics
      print('Fetching attendance stats for studentId=$studentIdToUse, classId=$classIdToUse');
      final stats = await attendanceService.getAttendanceStatsForStudent(
        classId: classIdToUse,
        studentId: studentIdToUse,
      );
      
      totalSessions.value = stats['totalSessions'] ?? 0;
      presentCount.value = stats['presentCount'] ?? 0;
      absentCount.value = stats['absentCount'] ?? 0;
      lateCount.value = stats['lateCount'] ?? 0;
      attendancePercentage.value = stats['attendancePercentage'] ?? 0.0;
      print('Attendance stats loaded: $stats');
      
      // Load attendance history
      print('Fetching attendance history for studentId=$studentIdToUse, classId=$classIdToUse');
      final history = await attendanceService.getStudentAttendanceHistory(
        classId: classIdToUse,
        studentId: studentIdToUse,
      );
      
      attendanceHistory.assignAll(history);
      print('Attendance history loaded: $history');
    } catch (e) {
      print('Error loading student data: ${e.toString()}');
      TSnackBar.showError(message: 'Failed to load student data: ${e.toString()}');
    } finally {
      isLoading.value = false;
      print('Finished loading student data');
    }
  }
  
  // Update attendance record
  Future<void> updateAttendanceRecord({
    required String sessionId,
    required String status,
    String? remarks,
  }) async {
    print('Updating attendance record: sessionId=$sessionId, status=$status, remarks=$remarks');
    try {
      isLoading.value = true;
      
      if (student.value == null) {
        print('Error: Student information is missing');
        TSnackBar.showError(message: 'Student information is missing');
        return;
      }
      
      await attendanceService.submitAttendance(
        sessionId: sessionId,
        studentId: student.value!.id,
        status: status,
        remarks: remarks,
      );
      print('Attendance record updated successfully');
      
      // Reload data to reflect changes
      await loadStudentData();
      
      TSnackBar.showSuccess(message: 'Attendance updated successfully');
    } catch (e) {
      print('Error updating attendance: ${e.toString()}');
      TSnackBar.showError(message: 'Failed to update attendance: ${e.toString()}');
    } finally {
      isLoading.value = false;
      print('Finished updating attendance record');
    }
  }
}
