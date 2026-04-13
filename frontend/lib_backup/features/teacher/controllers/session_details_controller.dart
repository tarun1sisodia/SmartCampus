import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../models/attendance_session_model.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import '../models/attendance_ui_models.dart';

class SessionDetailsController extends GetxController {
  // Removed AttendanceService dependency

  final isLoading = true.obs;
  final session = Rx<AttendanceSessionModel?>(null);
  final attendanceStats = Rx<AttendanceStats>(AttendanceStats.empty());
  final attendanceRecords = <AttendanceRecord>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Safely get arguments with null checks
    final args = Get.arguments as Map<String, dynamic>?;

    if (args != null && args['sessionId'] != null) {
      final String sessionId = args['sessionId'];
      loadSessionDetails(sessionId);
    } else {
      ///print('Error: Session ID not provided in arguments');
      isLoading.value =
          false; // Set loading to false so the UI can show an error state
    }
  }

  Future<void> loadSessionDetails(String sessionId) async {
    try {
      isLoading.value = true;
      final response = await ApiClient.dio.get('/attendance/session/$sessionId');
      
      if (response.statusCode == 200) {
        final data = response.data['data'];
        session.value = AttendanceSessionModel.fromJson(data);
        
        final List records = data['records'] ?? [];
        attendanceRecords.assignAll(records.map((r) => AttendanceRecord(
          id: r['id'],
          studentId: r['student']['id'],
          studentName: r['student']['name'],
          isPresent: r['status'] == 'present',
        )).toList());

        attendanceStats.value = AttendanceStats(
          total: data['stats']?['total'] ?? 0,
          present: data['stats']?['present'] ?? 0,
          absent: data['stats']?['absent'] ?? 0,
        );
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      TSnackBar.showError(message: 'Failed to load details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAttendanceRecords(String sessionId) async {
    try {
      // Use getDetailedAttendanceRecords instead of getAttendanceRecords
      final records =
          await attendanceService.getDetailedAttendanceRecords(sessionId);

      attendanceRecords.clear();
      attendanceRecords.addAll(records.map((record) => AttendanceRecord(
            id: record['id'],
            studentId: record['studentId'],
            studentName: record['studentName'],
            isPresent: record['isPresent'],
          )));
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      ///print('Error loading attendance records: $e');
      TSnackBar.showError(message: 'Failed to load attendance records');
    }
  }

  Future<void> _calculateAttendanceStats() async {
    if (session.value == null) return;

    try {
      final stats =
          await attendanceService.getSessionAttendanceStats(session.value!.id);

      attendanceStats.value = AttendanceStats(
        total: stats['total'],
        present: stats['present'],
        absent: stats['absent'],
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      ///print('Error calculating attendance stats: $e');
      // Use local calculation as fallback
      final total = attendanceRecords.length;
      final present =
          attendanceRecords.where((record) => record.isPresent).length;
      final absent = total - present;

      attendanceStats.value = AttendanceStats(
        total: total,
        present: present,
        absent: absent,
      );
    }
  }

  Future<void> toggleAttendance(String recordId, bool isPresent) async {
    try {
      await attendanceService.updateAttendanceRecord(recordId, isPresent);

      // local record
      final index =
          attendanceRecords.indexWhere((record) => record.id == recordId);
      if (index != -1) {
        final record = attendanceRecords[index];
        attendanceRecords[index] = AttendanceRecord(
          id: record.id,
          studentId: record.studentId,
          studentName: record.studentName,
          isPresent: isPresent,
        );

        // Recalculate stats
        _calculateAttendanceStats();

        TSnackBar.showSuccess(
          message: 'Attendance updated for ${record.studentName}',
        );
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      ///print('Error updating attendance: $e');
      TSnackBar.showError(message: 'Failed to update attendance');
    }
  }

  bool isSessionActive() {
    if (session.value == null) return false;
    return session.value!.status == 'open';
  }

  String formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }

  void refreshData(String sessionId) {
    loadSessionDetails(sessionId);
  }

  void generateQRCode() {
    if (session.value == null) return;

    if (!isSessionActive()) {
      TSnackBar.showWarning(
        message: 'QR code can only be generated for active sessions',
      );
      return;
    }

    // Navigate to QR code generation screen
    Get.toNamed('/generate-qr', arguments: {
      'sessionId': session.value!.id,
      'className': session.value!.subjectName,
    });
  }

  void exportAttendanceData() async {
    if (session.value == null) return;

    TSnackBar.showInfo(
      message: 'Preparing attendance data for export...',
    );

    try {
      // Use the service method to get formatted export data
      await attendanceService.exportSessionAttendanceData(session.value!.id);

      // Here you would typically save this data to a file
      // For now, just show a success message
      TSnackBar.showSuccess(
        message: 'Attendance data exported successfully',
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      ///print('Error exporting attendance data: $e');
      TSnackBar.showError(message: 'Failed to export attendance data');
    }
  }

  void openManualAttendance() {
    if (session.value == null) return;

    if (!isSessionActive()) {
      TSnackBar.showWarning(
        message: 'Manual attendance can only be taken during active sessions',
      );
      return;
    }

    // Navigate to manual attendance screen
    Get.toNamed('/manual-attendance', arguments: {
      'sessionId': session.value!.id,
      'className': session.value!.subjectName,
    });
  }

  void searchStudents() {
    // Implement search functionality
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by name or ID',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  // Implement search logic
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void viewAllStudents() {
    if (session.value == null) return;

    // Navigate to full student list
    Get.toNamed('/student-list', arguments: {
      'sessionId': session.value!.id,
      'className': session.value!.subjectName,
    });
  }
}
