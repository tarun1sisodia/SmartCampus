import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class TeacherService extends GetxService {
  final supabase = Supabase.instance.client;
  
  // Cache for teacher names to avoid repeated API calls
  final Map<String, String> _teacherNameCache = {};

  // Initialize the service
  Future<TeacherService> init() async {
    return this;
  }

  // Get teacher name by ID
  Future<String> getTeacherName(String teacherId) async {
    // Check cache first
    if (_teacherNameCache.containsKey(teacherId)) {
      return _teacherNameCache[teacherId]!;
    }

    try {
      // Query the profiles table to get the user's name
      final response = await supabase
          .from('profiles')
          .select('first_name, last_name, name')
          .eq('id', teacherId)
          .single();

      String teacherName = 'Unknown Teacher';
      
      // Try to get name from different possible fields
      if (response.containsKey('name') && response['name'] != null) {
        teacherName = response['name'] as String;
      } else {
        final firstName = response['first_name'] as String? ?? '';
        final lastName = response['last_name'] as String? ?? '';
        final fullName = '$firstName $lastName'.trim();
        
        if (fullName.isNotEmpty) {
          teacherName = fullName;
        }
      }

      // Cache the result
      _teacherNameCache[teacherId] = teacherName;
      
      return teacherName;
    } catch (e) {
      return 'Unknown Teacher';
    }
  }

  // Get teacher profile by ID
  Future<UserModel?> getTeacherProfile(String teacherId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', teacherId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Get all teachers
  Future<List<UserModel>> getAllTeachers() async {
    try {
      // Query users with teacher role
      final response = await supabase
          .from('profiles')
          .select()
          .eq('role', 'teacher')
          .order('name');

      return response.map<UserModel>((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get teacher classes
  Future<List<Map<String, dynamic>>> getTeacherClasses(String teacherId) async {
    try {
      final response = await supabase
          .from('classes')
          .select('*, subjects(*), courses(*)')
          .eq('teacher_id', teacherId)
          .order('created_at', ascending: false);

      return response;
    } catch (e) {
      return [];
    }
  }

  // Get teacher attendance summary
  Future<Map<String, dynamic>> getTeacherAttendanceSummary(String teacherId) async {
    try {
      // Get current month's stats
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      
      final response = await supabase
          .from('teacher_attendance_stats')
          .select()
          .eq('teacher_id', teacherId)
          .eq('month', startOfMonth.toIso8601String().split('T')[0])
          .single();

      return response;
    } catch (e) {
      // Return default values if no stats found
      return {
        'total_days': 0,
        'present_days': 0,
        'absent_days': 0,
        'late_days': 0,
        'excused_days': 0,
        'attendance_percentage': 0.0,
      };
    }
  }

  // Clear cache
  void clearCache() {
    _teacherNameCache.clear();
  }
}