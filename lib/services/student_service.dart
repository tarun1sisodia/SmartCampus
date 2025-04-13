import 'package:attedance__/models/student_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentService {
  final supabase = Supabase.instance.client;

  // Get all students for a class
  Future<List<StudentModel>> getStudentsForClass(String classId) async {
    try {
      final response = await supabase
          .from('class_students')
          .select('*, students(*)')
          .eq('class_id', classId)
          .order('created_at');

      return response.map<StudentModel>((json) {
        final studentData = json['students'] as Map<String, dynamic>;

        return StudentModel(
          id: studentData['id'],
          name: studentData['name'],
          rollNumber: studentData['roll_number'],
          classId: json['class_id'],
          createdAt:
              studentData['created_at'] != null
                  ? DateTime.parse(studentData['created_at'])
                  : null,
          updatedAt:
              studentData['updated_at'] != null
                  ? DateTime.parse(studentData['updated_at'])
                  : null,
        );
      }).toList();
    } catch (e) {
      throw 'Failed to get students: $e';
    }
  }

  // Add a student to a class
  Future<void> addStudentToClass({
    required String name,
    required String rollNumber,
    required String classId,
  }) async {
    try {
      // First, check if student with this roll number already exists
      final existingStudents = await supabase
          .from('students')
          .select()
          .eq('roll_number', rollNumber);

      String studentId;

      if (existingStudents.isNotEmpty) {
        // Student exists, use existing ID
        studentId = existingStudents[0]['id'];

        // Update student name if needed
        if (existingStudents[0]['name'] != name) {
          await supabase
              .from('students')
              .update({'name': name})
              .eq('id', studentId);
        }
      } else {
        // Create new student
        final studentData = {
          'name': name,
          'roll_number': rollNumber,
          'created_at': DateTime.now().toIso8601String(),
        };

        final response =
            await supabase
                .from('students')
                .insert(studentData)
                .select()
                .single();

        studentId = response['id'];
      }

      // Check if student is already in this class
      final existingClassStudents = await supabase
          .from('class_students')
          .select()
          .eq('class_id', classId)
          .eq('student_id', studentId);

      if (existingClassStudents.isEmpty) {
        // Add student to class
        await supabase.from('class_students').insert({
          'class_id': classId,
          'student_id': studentId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw 'Failed to add student to class: $e';
    }
  }

  // Remove a student from a class
  Future<void> removeStudentFromClass({
    required String studentId,
    required String classId,
  }) async {
    try {
      // Delete class-student relationship
      await supabase
          .from('class_students')
          .delete()
          .eq('class_id', classId)
          .eq('student_id', studentId);

      // Note: We don't delete the student record itself, as they might be in other classes
    } catch (e) {
      throw 'Failed to remove student from class: $e';
    }
  }

  // Get a student by ID
  Future<StudentModel> getStudentById(String studentId) async {
    try {
      final response =
          await supabase.from('students').select().eq('id', studentId).single();

      return StudentModel(
        id: response['id'],
        name: response['name'],
        rollNumber: response['roll_number'],
        classId: '', // This will be filled in by the caller if needed
        createdAt:
            response['created_at'] != null
                ? DateTime.parse(response['created_at'])
                : null,
        updatedAt:
            response['updated_at'] != null
                ? DateTime.parse(response['updated_at'])
                : null,
      );
    } catch (e) {
      throw 'Failed to get student: $e';
    }
  }
  // Add this method to the StudentService class

// Get all students
  Future<List<StudentModel>> getAllStudents() async {
    try {
      final response = await supabase.from('students').select().order('name');

      return response.map<StudentModel>((json) {
        return StudentModel(
          id: json['id'],
          name: json['name'],
          rollNumber: json['roll_number'],
          classId: '', // This will be empty since we're fetching all students
          createdAt: json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
          updatedAt: json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
        );
      }).toList();
    } catch (e) {
      throw 'Failed to get all students: $e';
    }
  }

}

