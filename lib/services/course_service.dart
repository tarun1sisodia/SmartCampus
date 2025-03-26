import 'package:attedance__/models/course_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CourseService {
  final supabase = Supabase.instance.client;

  // Get all courses
  Future<List<CourseModel>> getAllCourses() async {
    try {
      final response = await supabase.from('courses').select().order('name');

      return response.map<CourseModel>((json) {
        return CourseModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw 'Failed to get courses: $e';
    }
  }

  // Create a new course
  Future<CourseModel> createCourse(String name, String code) async {
    try {
      final data = {
        'name': name,
        'code': code,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response =
          await supabase.from('courses').insert(data).select().single();

      return CourseModel.fromJson(response);
    } catch (e) {
      throw 'Failed to create course: $e';
    }
  }

  // Get a course by ID
  Future<CourseModel> getCourseById(String courseId) async {
    try {
      final response =
          await supabase.from('courses').select().eq('id', courseId).single();

      return CourseModel.fromJson(response);
    } catch (e) {
      throw 'Failed to get course: $e';
    }
  }
}
