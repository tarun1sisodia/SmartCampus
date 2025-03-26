import 'package:attedance__/models/subject_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubjectService {
  final supabase = Supabase.instance.client;
  
  // Get all subjects
  Future<List<SubjectModel>> getAllSubjects() async {
    try {
      final response = await supabase
          .from('subjects')
          .select()
          .order('name');
      
      return response.map<SubjectModel>((json) {
        return SubjectModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw 'Failed to get subjects: $e';
    }
  }
  
  // Create a new subject
  Future<SubjectModel> createSubject(String name, String code) async {
    try {
      final data = {
        'name': name,
        'code': code,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final response = await supabase
          .from('subjects')
          .insert(data)
          .select()
          .single();
      
      return SubjectModel.fromJson(response);
    } catch (e) {
      throw 'Failed to create subject: $e';
    }
  }
  
  // Get a subject by ID
  Future<SubjectModel> getSubjectById(String subjectId) async {
    try {
      final response = await supabase
          .from('subjects')
          .select()
          .eq('id', subjectId)
          .single();
      
      return SubjectModel.fromJson(response);
    } catch (e) {
      throw 'Failed to get subject: $e';
    }
  }
}