import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/class_model.dart';

class ClassService {
  final supabase = Supabase.instance.client;

  // Get all classes for a teacher
  Future<List<ClassModel>> getTeacherClasses(String teacherId) async {
    final response = await supabase
        .from('classes')
        .select('''
          *,
          subject:subject_id(name),
          course:course_id(name)
        ''')
        .eq('teacher_id', teacherId)
        .order('created_at', ascending: false);
    
    return response.map((json) => ClassModel.fromJson({
      ...json,
      'subject_name': json['subject']['name'],
      'course_name': json['course']['name'],
    })).toList();
  }

  // Get a class by ID
  Future<ClassModel> getClassById(String id) async {
    final response = await supabase
        .from('classes')
        .select('''
          *,
          subject:subject_id(name),
          course:course_id(name)
        ''')
        .eq('id', id)
        .single();
    
    return ClassModel.fromJson({
      ...response,
      'subject_name': response['subject']['name'],
      'course_name': response['course']['name'],
    });
  }

  // Create a new class
  Future<ClassModel> createClass({
    required String teacherId,
    required String subjectId,
    required String courseId,
    required int year,
    String? section,
  }) async {
    final response = await supabase.from('classes').insert({
      'teacher_id': teacherId,
      'subject_id': subjectId,
      'course_id': courseId,
      'year': year,
      'section': section,
    }).select('''
      *,
      subject:subject_id(name),
      course:course_id(name)
    ''').single();
    
    return ClassModel.fromJson({
      ...response,
      'subject_name': response['subject']['name'],
      'course_name': response['course']['name'],
    });
  }

  // Update a class
  Future<ClassModel> updateClass({
    required String id,
    required String subjectId,
    required String courseId,
    required int year,
    String? section,
  }) async {
    final response = await supabase.from('classes').update({
      'subject_id': subjectId,
      'course_id': courseId,
      'year': year,
      'section': section,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id).select('''
      *,
      subject:subject_id(name),
      course:course_id(name)
    ''').single();
    
    return ClassModel.fromJson({
      ...response,
      'subject_name': response['subject']['name'],
      'course_name': response['course']['name'],
    });
  }

  // Delete a class
  Future<void> deleteClass(String id) async {
    // First delete all related records
    await supabase.from('class_students').delete().eq('class_id', id);
    
    // Then delete the class
    await supabase.from('classes').delete().eq('id', id);
  }
}