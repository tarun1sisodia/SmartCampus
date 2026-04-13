import 'package:smart_campus/common/utils/helpers/snackbar_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter/foundation.dart';

import '../models/class_model.dart';

class ClassService {
  final supabase = Supabase.instance.client;
  static const int defaultClassFetchLimit = 100;
  static const String _classSelectFields =
      'id, teacher_id, subject_id, course_id, semester, section, created_at, updated_at, subjects(name), courses(name)';

  // Get all classes for a teacher
  Future<List<ClassModel>> getTeacherClasses(
    String teacherId, {
    int limit = defaultClassFetchLimit,
    int offset = 0,
  }) async {
    try {
      //print('Fetching classes for teacher with ID: $teacherId');
      final response = await supabase
          .from('classes')
          .select(_classSelectFields)
          .eq('teacher_id', teacherId)
          .range(offset, offset + limit - 1)
          .order('created_at', ascending: false);

      //print('Classes fetched successfully: $response');
      return response.map<ClassModel>((json) {
        final subjectData = json['subjects'] as Map<String, dynamic>;
        final courseData = json['courses'] as Map<String, dynamic>;

        return ClassModel(
          id: json['id'],
          teacherId: json['teacher_id'],
          subjectId: json['subject_id'],
          courseId: json['course_id'],
          semester: json['semester'],
          section: json['section'],
          subjectName: subjectData['name'],
          courseName: courseData['name'],
          createdAt: json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
          updatedAt: json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
        );
      }).toList();
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      //print('Error fetching classes: $e');
      throw 'Failed to get teacher classes: $e';
    }
  }

  // Create a new class
  Future<ClassModel> createClass({
    required String teacherId,
    required String subjectId,
    required String courseId,
    required int semester,
    String? section,
  }) async {
    try {
      //print('Creating a new class for teacher ID: $teacherId');
      final data = {
        'teacher_id': teacherId,
        'subject_id': subjectId,
        'course_id': courseId,
        'semester': semester,
        'section': section,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from('classes')
          .insert(data)
          .select(_classSelectFields)
          .single();

      //print('Class created successfully: $response');
      final subjectData = response['subjects'] as Map<String, dynamic>;
      final courseData = response['courses'] as Map<String, dynamic>;

      return ClassModel(
        id: response['id'],
        teacherId: response['teacher_id'],
        subjectId: response['subject_id'],
        courseId: response['course_id'],
        semester: response['semester'],
        section: response['section'],
        subjectName: subjectData['name'],
        courseName: courseData['name'],
        createdAt: response['created_at'] != null
            ? DateTime.parse(response['created_at'])
            : null,
        updatedAt: response['updated_at'] != null
            ? DateTime.parse(response['updated_at'])
            : null,
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      //print('Error creating class: $e');
      throw 'Failed to create class: $e';
    }
  }

  // an existing class
  Future<ClassModel> updateClass({
    required String classId,
    required String subjectId,
    required String courseId,
    required int semester,
    String? section,
  }) async {
    try {
      //print('Updating class with ID: $classId');
      final data = {
        'subject_id': subjectId,
        'course_id': courseId,
        'semester': semester,
        'section': section,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from('classes')
          .update(data)
          .eq('id', classId)
          .select(_classSelectFields)
          .single();

      //print('Class updated successfully: $response');
      final subjectData = response['subjects'] as Map<String, dynamic>;
      final courseData = response['courses'] as Map<String, dynamic>;

      return ClassModel(
        id: response['id'],
        teacherId: response['teacher_id'],
        subjectId: response['subject_id'],
        courseId: response['course_id'],
        semester: response['semester'],
        section: response['section'],
        subjectName: subjectData['name'],
        courseName: courseData['name'],
        createdAt: response['created_at'] != null
            ? DateTime.parse(response['created_at'])
            : null,
        updatedAt: response['updated_at'] != null
            ? DateTime.parse(response['updated_at'])
            : null,
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      //print('Error updating class: $e');
      throw 'Failed to update class: $e';
    }
  }

  // Delete a class
  Future<void> deleteClass(String classId) async {
    try {
      debugPrint('Deleting class with ID: $classId');

      // 1. Get all session IDs for this class
      final List<Map<String, dynamic>> sessionRecords = await supabase
          .from('attendance_sessions')
          .select('id')
          .eq('class_id', classId);

      final sessionIds = sessionRecords.map((s) => s['id'] as String).toList();

      // 2. Delete all attendance records for these sessions
      if (sessionIds.isNotEmpty) {
        await supabase
            .from('attendance_records')
            .delete()
            .filter('session_id', 'in', sessionIds);
      }

      // 3. Delete attendance sessions
      await supabase
          .from('attendance_sessions')
          .delete()
          .eq('class_id', classId);

      // 4. Delete class-student relationships
      await supabase.from('class_students').delete().eq('class_id', classId);

      // 5. Finally delete the class
      await supabase.from('classes').delete().eq('id', classId);
      debugPrint('Class deleted successfully');
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      //print('Error deleting class: $e');
      TSnackBar.showError(message: 'Oops Failed to Delete Class');
      throw 'Failed to delete class: $e';
    }
  }

  // Get a class by ID
  Future<ClassModel> getClassById(String classId) async {
    try {
      //print('Fetching class with ID: $classId');
      final response = await supabase
          .from('classes')
          .select(_classSelectFields)
          .eq('id', classId)
          .single();

      //print('Class fetched successfully: $response');
      final subjectData = response['subjects'] as Map<String, dynamic>;
      final courseData = response['courses'] as Map<String, dynamic>;

      return ClassModel(
        id: response['id'],
        teacherId: response['teacher_id'],
        subjectId: response['subject_id'],
        courseId: response['course_id'],
        semester: response['semester'],
        section: response['section'],
        subjectName: subjectData['name'],
        courseName: courseData['name'],
        createdAt: response['created_at'] != null
            ? DateTime.parse(response['created_at'])
            : null,
        updatedAt: response['updated_at'] != null
            ? DateTime.parse(response['updated_at'])
            : null,
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      //print('Error fetching class: $e');
      throw 'Failed to get class: $e';
    }
  }
}
