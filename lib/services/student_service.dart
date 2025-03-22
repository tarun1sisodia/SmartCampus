import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_model.dart';

class StudentService {
  final supabase = Supabase.instance.client;

  // Get all students for a class
  Future<List<StudentModel>> getStudentsForClass(String classId) async {
    final response = await supabase
        .from('class_students')
        .select('student:student_id(*)')
        .eq('class_id', classId);
    
    return response.map((json) => StudentModel.fromJson(json['student'])).toList();
  }

  // Add a student to a class
  Future<StudentModel> addStudentToClass({
    required String name,
    required String rollNumber,
    required String courseId,
    required int year,
    String? section,
    required String classId,
  }) async {
    // First, check if the student already exists
    final existingStudents = await supabase
        .from('students')
        .select()
        .eq('roll_number', rollNumber)
        .eq('course_id', courseId)
        .eq('year', year);
    
    String studentId;
    
    if (existingStudents.isNotEmpty) {
      // Student already exists, use their ID
      studentId = existingStudents[0]['id'];
    } else {
      // Create a new student
      final newStudent = await supabase.from('students').insert({
        'name': name,
        'roll_number': rollNumber,
        'course_id': courseId,
        'year': year,
        'section': section,
      }).select().single();
      
      studentId = newStudent['id'];
    }
    
    // Now add the student to the class
    await supabase.from('class_students').insert({
      'class_id': classId,
      'student_id': studentId,
    });
    
    // Return the student model
    final studentData = await supabase
        .from('students')
        .select()
        .eq('id', studentId)
        .single();
    
    return StudentModel.fromJson(studentData);
  }

  // Remove a student from a class
  Future<void> removeStudentFromClass({
    required String studentId,
    required String classId,
  }) async {
    await supabase
        .from('class_students')
        .delete()
        .eq('class_id', classId)
        .eq('student_id', studentId);
  }

  // Get a student by ID
  Future<StudentModel> getStudentById(String id) async {
    final response = await supabase
        .from('students')
        .select()
        .eq('id', id)
        .single();
    
    return StudentModel.fromJson(response);
  }
}