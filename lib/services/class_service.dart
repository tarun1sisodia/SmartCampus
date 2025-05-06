import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/class_model.dart';

class ClassService {
  final supabase = Supabase.instance.client;

  // Get all classes for a teacher
  Future<List<ClassModel>> getTeacherClasses(String teacherId) async {
    try {
      //print('Fetching classes for teacher with ID: $teacherId');
      final response = await supabase
          .from('classes')
          .select('*, subjects(*), courses(*)')
          .eq('teacher_id', teacherId)
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
    } catch (e) {
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
          .select('*, subjects(*), courses(*)')
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
    } catch (e) {
      //print('Error creating class: $e');
      throw 'Failed to create class: $e';
    }
  }

  // Update an existing class
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
          .select('*, subjects(*), courses(*)')
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
    } catch (e) {
      //print('Error updating class: $e');
      throw 'Failed to update class: $e';
    }
  }

  // Delete a class
  Future<void> deleteClass(String classId) async {
    try {
      //print('Deleting class with ID: $classId');
      // First delete all related records
      await supabase.from('attendance_records').delete().eq(
            'session_id',
            supabase
                .from('attendance_sessions')
                .select('id')
                .eq('class_id', classId),
          );

      // Delete attendance sessions
      await supabase
          .from('attendance_sessions')
          .delete()
          .eq('class_id', classId);

      // Delete class-student relationships
      await supabase.from('class_students').delete().eq('class_id', classId);

      // Finally delete the class
      await supabase.from('classes').delete().eq('id', classId);
      //print('Class deleted successfully');
    } catch (e) {
      //print('Error deleting class: $e');
      throw 'Failed to delete class: $e';
    }
  }

  // Get a class by ID
  Future<ClassModel> getClassById(String classId) async {
    try {
      //print('Fetching class with ID: $classId');
      final response = await supabase
          .from('classes')
          .select('*, subjects(*), courses(*)')
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
    } catch (e) {
      //print('Error fetching class: $e');
      throw 'Failed to get class: $e';
    }
  }
}
