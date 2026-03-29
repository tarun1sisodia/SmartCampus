import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_model.dart';
import '../models/attendance_record_model.dart';
import '../models/attendance_session_model.dart';
import '../models/class_model.dart';
import 'local_storage_service.dart';
import 'class_service.dart';
import 'subject_service.dart';
import 'course_service.dart';
import 'student_service.dart';
import 'attendance_service.dart';

class SyncService extends GetxService {
  static SyncService get instance => Get.put<SyncService>(SyncService());

  final _localStorage = LocalStorageService();
  final _supabase = Supabase.instance.client;

  // Inject your existing services
  final _classService = ClassService();
  final _subjectService = SubjectService();
  final _courseService = CourseService();
  final _studentService = StudentService();
  final _attendanceService = AttendanceService();

  final RxBool isSyncing = false.obs;
  final RxString syncStatus = ''.obs;
  final RxDouble syncProgress = 0.0.obs;
  final RxBool isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    _checkConnectivity();
    _startPeriodicSync();
  }

  // Check internet connectivity
  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      isOnline.value = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      isOnline.value = false;
    }
  }

  // Start periodic sync every 5 minutes when online
  void _startPeriodicSync() {
    Stream.periodic(const Duration(minutes: 5)).listen((_) async {
      await _checkConnectivity();
      if (isOnline.value && !isSyncing.value) {
        await syncAllData();
      }
    });
  }

  // Sync all data
  Future<bool> syncAllData() async {
    if (isSyncing.value) return false;

    try {
      isSyncing.value = true;
      syncStatus.value = 'Starting sync...';
      syncProgress.value = 0.0;

      await _checkConnectivity();
      if (!isOnline.value) {
        syncStatus.value = 'No internet connection';
        return false;
      }

      // Step 1: Download fresh data from server (20%)
      syncStatus.value = 'Downloading data..20%.';
      await _downloadDataFromServer();
      syncProgress.value = 0.2;

      // Step 2: Upload pending local changes (40%)
      syncStatus.value = 'Uploading local changes...40%';
      await _uploadPendingChanges();
      syncProgress.value = 0.6;

      // Step 3: Resolve conflicts (20%)
      syncStatus.value = 'Resolving conflicts...20%';
      await _resolveConflicts();
      syncProgress.value = 0.8;

      // Step 4: Clean up and finalize (20%)
      syncStatus.value = 'Finalizing...20%';
      await _cleanupSyncData();
      syncProgress.value = 1.0;

      syncStatus.value = 'Sync completed successfully';
      await _localStorage.saveLastSyncTime(DateTime.now());

      return true;
    } catch (e) {
      syncStatus.value = 'Sync failed: ${e.toString()}';
      debugPrint('Sync error: $e');
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  // Download fresh data from server
  Future<void> _downloadDataFromServer() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;

    try {
      // Download subjects
      final subjects = await _subjectService.getAllSubjects();
      for (final subject in subjects) {
        await _localStorage.saveSubjectOffline(subject);
      }

      // Download courses
      final courses = await _courseService.getAllCourses();
      for (final course in courses) {
        await _localStorage.saveCourseOffline(course);
      }

      // Download teacher's classes
      final classes = await _classService.getTeacherClasses(currentUser.id);
      for (final classModel in classes) {
        await _localStorage.saveClassOffline(classModel);

        // Download students for each class
        final students =
            await _studentService.getStudentsForClass(classModel.id);
        for (final student in students) {
          await _localStorage.saveStudentOffline(student);
          await _localStorage.addStudentToClassOffline(
              classModel.id, student.id);
        }

        // Download attendance sessions for each class
        final sessions =
            await _attendanceService.getAttendanceSessions(classModel.id);
        for (final session in sessions) {
          await _localStorage.saveAttendanceSessionOffline(session);

          // Download attendance records for each session
          final records =
              await _attendanceService.getAttendanceRecords(session.id);
          for (final record in records) {
            await _localStorage.saveAttendanceRecordOffline(record);
          }
        }
      }
    } catch (e) {
      debugPrint('Error downloading data from server: $e');
      rethrow;
    }
  }

  // Upload pending local changes
  Future<void> _uploadPendingChanges() async {
    try {
      // Upload classes
      await _uploadUnsyncedClasses();

      // Upload students
      await _uploadUnsyncedStudents();

      // Upload attendance sessions
      await _uploadUnsyncedAttendanceSessions();

      // Upload attendance records
      await _uploadUnsyncedAttendanceRecords();
    } catch (e) {
      debugPrint('Error uploading pending changes: $e');
      rethrow;
    }
  }

// Replace the problematic methods in SyncService with these corrected versions:

  Future<void> _uploadUnsyncedClasses() async {
    final unsyncedClasses = await _localStorage.getUnsyncedRecords('classes');

    for (final classData in unsyncedClasses) {
      try {
        final classModel = ClassModel.fromJson(classData);

        // Check if class exists on server
        try {
          await _classService.getClassById(classModel.id);
          // Class exists, update it
          await _classService.updateClass(
            classId: classModel.id,
            subjectId: classModel.subjectId,
            courseId: classModel.courseId,
            semester: classModel.semester,
            section: classModel.section,
          );
        } catch (e) {
          // Class doesn't exist, create it
          await _classService.createClass(
            teacherId: classModel.teacherId,
            subjectId: classModel.subjectId,
            courseId: classModel.courseId,
            semester: classModel.semester,
            section: classModel.section,
          );
        }

        // Mark as synced
        await _localStorage.markAsSynced('classes', classModel.id);
      } catch (e) {
        debugPrint('Error uploading class ${classData['id']}: $e');
        // Add to retry queue or mark for manual resolution
        await _localStorage.addToSyncQueue(
            'classes', classData['id'], 'RETRY_UPLOAD', classData);
      }
    }
  }

  Future<void> _uploadUnsyncedStudents() async {
    final unsyncedStudents = await _localStorage.getUnsyncedRecords('students');

    for (final studentData in unsyncedStudents) {
      try {
        final student = StudentModel.fromJson(studentData);

        // Add student to class (this will create or update the student)
        await _studentService.addStudentToClass(
          name: student.name,
          rollNumber: student.rollNumber,
          classId: student.classId,
        );

        // Mark as synced
        await _localStorage.markAsSynced('students', student.id);
      } catch (e) {
        debugPrint('Error uploading student ${studentData['id']}: $e');
        // Add to retry queue
        await _localStorage.addToSyncQueue(
            'students', studentData['id'], 'RETRY_UPLOAD', studentData);
      }
    }
  }

  Future<void> _uploadUnsyncedAttendanceSessions() async {
    final unsyncedSessions =
        await _localStorage.getUnsyncedRecords('attendance_sessions');

    for (final sessionData in unsyncedSessions) {
      try {
        final session = AttendanceSessionModel.fromJson(sessionData);

        // Create attendance session
        await _attendanceService.createAttendanceSession(
          classId: session.classId,
          date: session.date,
          startTime: session.startTime,
          endTime: session.endTime,
          createdBy: session.createdBy ?? '',
        );

        // Mark as synced
        await _localStorage.markAsSynced('attendance_sessions', session.id);
      } catch (e) {
        debugPrint(
            'Error uploading attendance session ${sessionData['id']}: $e');
        // Add to retry queue
        await _localStorage.addToSyncQueue('attendance_sessions',
            sessionData['id'], 'RETRY_UPLOAD', sessionData);
      }
    }
  }

  Future<void> _uploadUnsyncedAttendanceRecords() async {
    final unsyncedRecords =
        await _localStorage.getUnsyncedRecords('attendance_records');

    for (final recordData in unsyncedRecords) {
      try {
        final record = AttendanceRecordModel.fromJson(recordData);

        // Submit attendance
        await _attendanceService.submitAttendance(
          sessionId: record.sessionId,
          studentId: record.studentId,
          status: record.status,
          remarks: record.remarks,
        );

        // Mark as synced
        await _localStorage.markAsSynced('attendance_records', record.id);
      } catch (e) {
        debugPrint('Error uploading attendance record ${recordData['id']}: $e');
        // Add to retry queue
        await _localStorage.addToSyncQueue(
            'attendance_records', recordData['id'], 'RETRY_UPLOAD', recordData);
      }
    }
  }

// Update the conflict resolution method
  Future<void> _resolveConflicts() async {
    try {
      final tables = [
        'classes',
        'students',
        'attendance_sessions',
        'attendance_records'
      ];

      for (final table in tables) {
        final conflictedRecords =
            await _localStorage.getConflictedRecords(table);

        for (final recordData in conflictedRecords) {
          try {
            final recordId = recordData['id'];

            // For now, implement server-wins strategy
            // In a more sophisticated system, you might want to show conflict resolution UI
            switch (table) {
              case 'classes':
                try {
                  final serverClass =
                      await _classService.getClassById(recordId);
                  await _localStorage.saveClassOffline(serverClass);
                } catch (e) {
                  // Record doesn't exist on server, keep local version
                  debugPrint(
                      'Class $recordId not found on server, keeping local version');
                }
                break;

              case 'students':
                // For students, we'll keep the local version since student data is usually more current locally
                debugPrint('Keeping local version of student $recordId');
                break;

              case 'attendance_sessions':
                // For attendance sessions, server wins
                try {
                  final sessions = await _attendanceService
                      .getAttendanceSessions(recordData['class_id']);
                  final serverSession =
                      sessions.firstWhere((s) => s.id == recordId);
                  await _localStorage
                      .saveAttendanceSessionOffline(serverSession);
                } catch (e) {
                  debugPrint(
                      'Attendance session $recordId not found on server');
                }
                break;

              case 'attendance_records':
                // For attendance records, server wins
                try {
                  final records = await _attendanceService
                      .getAttendanceRecords(recordData['session_id']);
                  final serverRecord =
                      records.firstWhere((r) => r.id == recordId);
                  await _localStorage.saveAttendanceRecordOffline(serverRecord);
                } catch (e) {
                  debugPrint('Attendance record $recordId not found on server');
                }
                break;
            }
          } catch (e) {
            debugPrint(
                'Error resolving conflict for $table record ${recordData['id']}: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error resolving conflicts: $e');
    }
  }

  // Clean up sync data
  Future<void> _cleanupSyncData() async {
    try {
      // Remove old sync queue items
      final oldSyncItems = await _localStorage.getRecords('sync_queue',
          where: 'created_at < ?',
          whereArgs: [
            DateTime.now().subtract(const Duration(days: 7)).toIso8601String()
          ]);

      for (final item in oldSyncItems) {
        await _localStorage.removeSyncQueueItem(item['id']);
      }
    } catch (e) {
      debugPrint('Error cleaning up sync data: $e');
    }
  }

  // Force sync specific data type
  Future<bool> syncClasses() async {
    try {
      syncStatus.value = 'Syncing classes...';
      await _uploadUnsyncedClasses();

      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null) {
        final classes = await _classService.getTeacherClasses(currentUser.id);
        for (final classModel in classes) {
          await _localStorage.saveClassOffline(classModel);
        }
      }

      syncStatus.value = 'Classes synced successfully';
      return true;
    } catch (e) {
      syncStatus.value = 'Failed to sync classes: ${e.toString()}';
      return false;
    }
  }

  Future<bool> syncStudents() async {
    try {
      syncStatus.value = 'Syncing students...';
      await _uploadUnsyncedStudents();

      // Download fresh student data for all classes
      final classes = await _localStorage.getOfflineClasses();
      for (final classModel in classes) {
        final students =
            await _studentService.getStudentsForClass(classModel.id);
        for (final student in students) {
          await _localStorage.saveStudentOffline(student);
        }
      }

      syncStatus.value = 'Students synced successfully';
      return true;
    } catch (e) {
      syncStatus.value = 'Failed to sync students: ${e.toString()}';
      return false;
    }
  }

  Future<bool> syncAttendance() async {
    try {
      syncStatus.value = 'Syncing attendance...';
      await _uploadUnsyncedAttendanceSessions();
      await _uploadUnsyncedAttendanceRecords();

      // Download fresh attendance data
      final classes = await _localStorage.getOfflineClasses();
      for (final classModel in classes) {
        final sessions =
            await _attendanceService.getAttendanceSessions(classModel.id);
        for (final session in sessions) {
          await _localStorage.saveAttendanceSessionOffline(session);

          final records =
              await _attendanceService.getAttendanceRecords(session.id);
          for (final record in records) {
            await _localStorage.saveAttendanceRecordOffline(record);
          }
        }
      }

      syncStatus.value = 'Attendance synced successfully';
      return true;
    } catch (e) {
      syncStatus.value = 'Failed to sync attendance: ${e.toString()}';
      return false;
    }
  }

  // Get sync status info
  Map<String, dynamic> getSyncInfo() {
    final lastSync = _localStorage.getLastSyncTime();
    return {
      'is_syncing': isSyncing.value,
      'sync_status': syncStatus.value,
      'sync_progress': syncProgress.value,
      'is_online': isOnline.value,
      'last_sync': lastSync?.toIso8601String(),
      'last_sync_formatted': lastSync != null
          ? '${lastSync.day}/${lastSync.month}/${lastSync.year} ${lastSync.hour}:${lastSync.minute}'
          : 'Never',
    };
  }

  // Manual connectivity check
  Future<void> checkConnectivity() async {
    await _checkConnectivity();
  }

  // Get pending sync count
  Future<int> getPendingSyncCount() async {
    try {
      final pendingClasses = await _localStorage.getUnsyncedRecords('classes');
      final pendingStudents =
          await _localStorage.getUnsyncedRecords('students');
      final pendingSessions =
          await _localStorage.getUnsyncedRecords('attendance_sessions');
      final pendingRecords =
          await _localStorage.getUnsyncedRecords('attendance_records');

      return pendingClasses.length +
          pendingStudents.length +
          pendingSessions.length +
          pendingRecords.length;
    } catch (e) {
      debugPrint('Error getting pending sync count: $e');
      return 0;
    }
  }

  // Reset sync status
  void resetSyncStatus() {
    isSyncing.value = false;
    syncStatus.value = '';
    syncProgress.value = 0.0;
  }
}
