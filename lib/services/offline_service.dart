import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/student_model.dart';
import '../models/attendance_record_model.dart';
import '../models/attendance_session_model.dart';
import '../models/class_model.dart';
import '../models/course_model.dart';
import '../models/subject_model.dart';
import 'local_storage_service.dart';
import 'sync_service.dart';
import 'class_service.dart';
import 'subject_service.dart';
import 'course_service.dart';
import 'student_service.dart';
import 'attendance_service.dart';

/// Offline-first service that wraps your existing services
/// Always tries local storage first, then falls back to online services
class OfflineService extends GetxService {
  static OfflineService get instance => Get.find();

  // final _localStorage = LocalStorageService.instance;
    final _localStorage = LocalStorageService();

  final _syncService = SyncService.instance;

  // Your existing services
  final _classService = ClassService();
  final _subjectService = SubjectService();
  final _courseService = CourseService();
  final _studentService = StudentService();
  final _attendanceService = AttendanceService();
  // Initialize method for GetX bindings

  // ==================== Class Operations ====================

  Future<List<ClassModel>> getTeacherClasses(String teacherId) async {
    try {
      // Always try local first
      final localClasses =
          await _localStorage.getOfflineClasses(teacherId: teacherId);

      if (localClasses.isNotEmpty) {
        // If we have local data, return it and sync in background
        if (_syncService.isOnline.value && !_syncService.isSyncing.value) {
          _syncService.syncClasses();
        }
        return localClasses;
      }

      // If no local data and we're online, fetch from server
      if (_syncService.isOnline.value) {
        final onlineClasses = await _classService.getTeacherClasses(teacherId);

        // Save to local storage
        for (final classModel in onlineClasses) {
          await _localStorage.saveClassOffline(classModel);
        }

        return onlineClasses;
      }

      // No local data and offline
      return [];
    } catch (e) {
      debugPrint('Error getting teacher classes: $e');
      // Fallback to local data even if there's an error
      return await _localStorage.getOfflineClasses(teacherId: teacherId);
    }
  }

  Future<ClassModel?> createClass({
    required String teacherId,
    required String subjectId,
    required String courseId,
    required int semester,
    String? section,
  }) async {
    try {
      if (_syncService.isOnline.value) {
        // Online: Create on server and save locally
        final newClass = await _classService.createClass(
          teacherId: teacherId,
          subjectId: subjectId,
          courseId: courseId,
          semester: semester,
          section: section,
        );

        await _localStorage.saveClassOffline(newClass);
        return newClass;
      } else {
        // Offline: Create locally and queue for sync
        final classId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
        final newClass = ClassModel(
          id: classId,
          teacherId: teacherId,
          subjectId: subjectId,
          courseId: courseId,
          semester: semester,
          section: section,
          createdAt: DateTime.now(),
        );

        await _localStorage.saveClassOffline(newClass);
        await _localStorage.addToSyncQueue(
            'classes', classId, 'CREATE', newClass.toJson());

        return newClass;
      }
    } catch (e) {
      debugPrint('Error creating class: $e');
      return null;
    }
  }

  // ==================== Student Operations ====================

  Future<List<StudentModel>> getStudentsForClass(String classId) async {
    try {
      // Always try local first
      final localStudents =
          await _localStorage.getOfflineStudents(classId: classId);

      if (localStudents.isNotEmpty) {
        // If we have local data, return it and sync in background
        if (_syncService.isOnline.value && !_syncService.isSyncing.value) {
          _syncService.syncStudents();
        }
        return localStudents;
      }

      // If no local data and we're online, fetch from server
      if (_syncService.isOnline.value) {
        final onlineStudents =
            await _studentService.getStudentsForClass(classId);

        // Save to local storage
        for (final student in onlineStudents) {
          await _localStorage.saveStudentOffline(student);
          await _localStorage.addStudentToClassOffline(classId, student.id);
        }

        return onlineStudents;
      }

      // No local data and offline
      return [];
    } catch (e) {
      debugPrint('Error getting students for class: $e');
      return await _localStorage.getOfflineStudents(classId: classId);
    }
  }

  Future<StudentModel?> addStudentToClass({
    required String name,
    required String rollNumber,
    required String classId,
  }) async {
    try {
      if (_syncService.isOnline.value) {
        // Online: Add on server and save locally
        await _studentService.addStudentToClass(
          name: name,
          rollNumber: rollNumber,
          classId: classId,
        );

        // Since addStudentToClass returns void, we need to fetch the student
        // or create a StudentModel manually
        final students = await _studentService.getStudentsForClass(classId);
        final newStudent = students.firstWhere(
          (student) => student.rollNumber == rollNumber,
          orElse: () => StudentModel(
            id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
            name: name,
            rollNumber: rollNumber,
            classId: classId,
            createdAt: DateTime.now(),
          ),
        );

        await _localStorage.saveStudentOffline(newStudent);
        await _localStorage.addStudentToClassOffline(classId, newStudent.id);

        return newStudent;
      } else {
        // Offline: Create locally and queue for sync
        final studentId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
        final newStudent = StudentModel(
          id: studentId,
          name: name,
          rollNumber: rollNumber,
          classId: classId,
          createdAt: DateTime.now(),
        );

        await _localStorage.saveStudentOffline(newStudent);
        await _localStorage.addStudentToClassOffline(classId, studentId);
        await _localStorage.addToSyncQueue(
            'students', studentId, 'CREATE', newStudent.toJson());

        return newStudent;
      }
    } catch (e) {
      debugPrint('Error adding student to class: $e');
      return null;
    }
  }
  // ==================== Attendance Operations ====================

  Future<List<AttendanceSessionModel>> getAttendanceSessions(
      String classId) async {
    try {
      // Always try local first
      final localSessions =
          await _localStorage.getOfflineAttendanceSessions(classId: classId);

      if (localSessions.isNotEmpty) {
        // If we have local data, return it and sync in background
        if (_syncService.isOnline.value && !_syncService.isSyncing.value) {
          _syncService.syncAttendance();
        }
        return localSessions;
      }

      // If no local data and we're online, fetch from server
      if (_syncService.isOnline.value) {
        final onlineSessions =
            await _attendanceService.getAttendanceSessions(classId);

        // Save to local storage
        for (final session in onlineSessions) {
          await _localStorage.saveAttendanceSessionOffline(session);
        }

        return onlineSessions;
      }

      // No local data and offline
      return [];
    } catch (e) {
      debugPrint('Error getting attendance sessions: $e');
      return await _localStorage.getOfflineAttendanceSessions(classId: classId);
    }
  }

  Future<AttendanceSessionModel?> createAttendanceSession({
    required String classId,
    required DateTime date,
    String? startTime,
    String? endTime,
    required String createdBy,
  }) async {
    try {
      if (_syncService.isOnline.value) {
        // Online: Create on server and save locally
        final newSession = await _attendanceService.createAttendanceSession(
          classId: classId,
          date: date,
          startTime: startTime,
          endTime: endTime,
          createdBy: createdBy,
        );

        await _localStorage.saveAttendanceSessionOffline(newSession);
        return newSession;
      } else {
        // Offline: Create locally and queue for sync
        final sessionId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
        final newSession = AttendanceSessionModel(
          id: sessionId,
          classId: classId,
          date: date,
          startTime: startTime,
          endTime: endTime,
          createdBy: createdBy,
          createdAt: DateTime.now(),
        );

        await _localStorage.saveAttendanceSessionOffline(newSession);
        await _localStorage.addToSyncQueue(
            'attendance_sessions', sessionId, 'CREATE', newSession.toJson());

        return newSession;
      }
    } catch (e) {
      debugPrint('Error creating attendance session: $e');
      return null;
    }
  }

  Future<List<AttendanceRecordModel>> getAttendanceRecords(
      String sessionId) async {
    try {
      // Always try local first
      final localRecords =
          await _localStorage.getOfflineAttendanceRecords(sessionId: sessionId);

      if (localRecords.isNotEmpty) {
        // If we have local data, return it and sync in background
        if (_syncService.isOnline.value && !_syncService.isSyncing.value) {
          _syncService.syncAttendance();
        }
        return localRecords;
      }

      // If no local data and we're online, fetch from server
      if (_syncService.isOnline.value) {
        final onlineRecords =
            await _attendanceService.getAttendanceRecords(sessionId);

        // Save to local storage
        for (final record in onlineRecords) {
          await _localStorage.saveAttendanceRecordOffline(record);
        }

        return onlineRecords;
      }

      // No local data and offline
      return [];
    } catch (e) {
      debugPrint('Error getting attendance records: $e');
      return await _localStorage.getOfflineAttendanceRecords(
          sessionId: sessionId);
    }
  }

  Future<bool> submitAttendance({
    required String sessionId,
    required String studentId,
    required String status,
    String? remarks,
  }) async {
    try {
      if (_syncService.isOnline.value) {
        // Online: Submit to server and save locally
        try {
          await _attendanceService.submitAttendance(
            sessionId: sessionId,
            studentId: studentId,
            status: status,
            remarks: remarks,
          );

          // Since submitAttendance returns void, we assume success if no exception
          final recordId = '${sessionId}_$studentId';
          final record = AttendanceRecordModel(
            id: recordId,
            sessionId: sessionId,
            studentId: studentId,
            status: status,
            remarks: remarks,
            createdAt: DateTime.now(),
          );

          await _localStorage.saveAttendanceRecordOffline(record);
          return true;
        } catch (e) {
          debugPrint('Error submitting attendance to server: $e');
          return false;
        }
      } else {
        // Offline: Save locally and queue for sync
        final recordId =
            'offline_${sessionId}_${studentId}_${DateTime.now().millisecondsSinceEpoch}';
        final record = AttendanceRecordModel(
          id: recordId,
          sessionId: sessionId,
          studentId: studentId,
          status: status,
          remarks: remarks,
          createdAt: DateTime.now(),
        );

        await _localStorage.saveAttendanceRecordOffline(record);
        await _localStorage.addToSyncQueue(
            'attendance_records', recordId, 'CREATE', record.toJson());

        return true;
      }
    } catch (e) {
      debugPrint('Error submitting attendance: $e');
      return false;
    }
  }
  // ==================== Subject and Course Operations ====================

  Future<List<SubjectModel>> getAllSubjects() async {
    try {
      // Always try local first
      final localSubjects = await _localStorage.getOfflineSubjects();

      if (localSubjects.isNotEmpty) {
        return localSubjects;
      }

      // If no local data and we're online, fetch from server
      if (_syncService.isOnline.value) {
        final onlineSubjects = await _subjectService.getAllSubjects();

        // Save to local storage
        for (final subject in onlineSubjects) {
          await _localStorage.saveSubjectOffline(subject);
        }

        return onlineSubjects;
      }

      return [];
    } catch (e) {
      debugPrint('Error getting subjects: $e');
      return await _localStorage.getOfflineSubjects();
    }
  }

  Future<List<CourseModel>> getAllCourses() async {
    try {
      // Always try local first
      final localCourses = await _localStorage.getOfflineCourses();

      if (localCourses.isNotEmpty) {
        return localCourses;
      }

      // If no local data and we're online, fetch from server
      if (_syncService.isOnline.value) {
        final onlineCourses = await _courseService.getAllCourses();

        // Save to local storage
        for (final course in onlineCourses) {
          await _localStorage.saveCourseOffline(course);
        }

        return onlineCourses;
      }

      return [];
    } catch (e) {
      debugPrint('Error getting courses: $e');
      return await _localStorage.getOfflineCourses();
    }
  }

  // ==================== Statistics ====================

  Future<Map<String, dynamic>> getAttendanceStats(String classId) async {
    try {
      if (_syncService.isOnline.value) {
        // Try to get fresh stats from server
        try {
          final onlineStats =
              await _attendanceService.getAttendanceStatsForClass(classId);
          return onlineStats;
        } catch (e) {
          // If server fails, fall back to local stats
          debugPrint('Failed to get online stats, using local: $e');
        }
      }

      // Get stats from local data
      return await _localStorage.getOfflineAttendanceStats(classId);
    } catch (e) {
      debugPrint('Error getting attendance stats: $e');
      return {
        'total_sessions': 0,
        'total_present': 0,
        'total_absent': 0,
        'total_late': 0,
        'total_excused': 0,
        'attendance_percentage': 0.0,
      };
    }
  }

  // ==================== Bulk Operations ====================

  Future<bool> bulkSubmitAttendance({
    required String sessionId,
    required List<Map<String, dynamic>> attendanceData,
  }) async {
    try {
      if (_syncService.isOnline.value) {
        // Online: Submit to server
        try {
          await _attendanceService.submitBulkAttendance(
            sessionId: sessionId,
            records: attendanceData,
          );

          // Since submitBulkAttendance returns void, assume success if no exception
          // Save all records locally
          final records = attendanceData.map((data) {
            final recordId = '${sessionId}_${data['student_id']}';
            return AttendanceRecordModel(
              id: recordId,
              sessionId: sessionId,
              studentId: data['student_id'],
              status: data['status'],
              remarks: data['remarks'],
              createdAt: DateTime.now(),
            );
          }).toList();

          await _localStorage.saveMultipleAttendanceRecordsOffline(records);
          return true;
        } catch (e) {
          debugPrint('Error submitting bulk attendance to server: $e');
          return false;
        }
      } else {
        // Offline: Save all records locally and queue for sync
        final records = attendanceData.map((data) {
          final recordId =
              'offline_${sessionId}_${data['student_id']}_${DateTime.now().millisecondsSinceEpoch}';
          return AttendanceRecordModel(
            id: recordId,
            sessionId: sessionId,
            studentId: data['student_id'],
            status: data['status'],
            remarks: data['remarks'],
            createdAt: DateTime.now(),
          );
        }).toList();

        await _localStorage.saveMultipleAttendanceRecordsOffline(records);

        // Add to sync queue
        for (final record in records) {
          await _localStorage.addToSyncQueue(
              'attendance_records', record.id, 'CREATE', record.toJson());
        }

        return true;
      }
    } catch (e) {
      debugPrint('Error bulk submitting attendance: $e');
      return false;
    }
  }
  // ==================== Utility Methods ====================

  Future<bool> isDataAvailableOffline() async {
    try {
      final classes = await _localStorage.getOfflineClasses();
      return classes.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<DateTime?> getLastSyncTime() async {
    return _localStorage.getLastSyncTime();
  }

  Future<int> getPendingSyncCount() async {
    return await _syncService.getPendingSyncCount();
  }

  Map<String, dynamic> getConnectionStatus() {
    return {
      'is_online': _syncService.isOnline.value,
      'is_syncing': _syncService.isSyncing.value,
      'sync_status': _syncService.syncStatus.value,
      'sync_progress': _syncService.syncProgress.value,
    };
  }
}
