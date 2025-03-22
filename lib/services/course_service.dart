import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_model.dart';

class CourseService {
  final supabase = Supabase.instance.client;

  // Get all courses
  Future<List<CourseModel>> getAllCourses() async {
    final response = await supabase
        .from('courses')
        .select()
        .order('name', ascending: true);

    return response.map((json) => CourseModel.fromJson(json)).toList();
  }

  // Get course by ID
  Future<CourseModel> getCourseById(String id) async {
    final response =
        await supabase.from('courses').select().eq('id', id).single();

    return CourseModel.fromJson(response);
  }

  // Create a new course
  Future<CourseModel> createCourse(String name, String? code) async {
    final response =
        await supabase
            .from('courses')
            .insert({'name': name, 'code': code})
            .select()
            .single();

    return CourseModel.fromJson(response);
  }

  // Update a course
  Future<CourseModel> updateCourse(String id, String name, String? code) async {
    final response =
        await supabase
            .from('courses')
            .update({
              'name': name,
              'code': code,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', id)
            .select()
            .single();

    return CourseModel.fromJson(response);
  }

  // Delete a course
  Future<void> deleteCourse(String id) async {
    await supabase.from('courses').delete().eq('id', id);
  }
}
