import 'package:attedance__/models/course_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CourseService {
  final supabase = Supabase.instance.client;

  // Get all courses
  Future<List<CourseModel>> getAllCourses() async {
    try {
      //print('Fetching all courses...');
      final response = await supabase.from('courses').select().order('name');
      //print('Successfully fetched courses: $response');

      return response.map<CourseModel>((json) {
        return CourseModel.fromJson(json);
      }).toList();
    } catch (e) {
      //print('Error while fetching courses: $e');
      throw 'Failed to get courses: $e';
    }
  }

  // Create a new course
  Future<CourseModel> createCourse(String name, String code) async {
    try {
      //print('Creating a new course with name: $name, code: $code...');
      final data = {
        'name': name,
        'code': code,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response =
          await supabase.from('courses').insert(data).select().single();
      //print('Successfully created course: $response');

      return CourseModel.fromJson(response);
    } catch (e) {
      //print('Error while creating course: $e');
      throw 'Failed to create course: $e';
    }
  }

  // Get a course by ID
  Future<CourseModel> getCourseById(String courseId) async {
    try {
      //print('Fetching course with ID: $courseId...');
      final response =
          await supabase.from('courses').select().eq('id', courseId).single();
      //print('Successfully fetched course: $response');

      return CourseModel.fromJson(response);
    } catch (e) {
      //print('Error while fetching course: $e');
      throw 'Failed to get course: $e';
    }
  }
}
