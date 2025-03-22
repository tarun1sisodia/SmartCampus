import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subject_model.dart';

class SubjectService {
  final supabase = Supabase.instance.client;

  // Get all subjects
  Future<List<SubjectModel>> getAllSubjects() async {
    final response = await supabase
        .from('subjects')
        .select()
        .order('name', ascending: true);
    
    return response.map((json) => SubjectModel.fromJson(json)).toList();
  }

  // Get subject by ID
  Future<SubjectModel> getSubjectById(String id) async {
    final response = await supabase
        .from('subjects')
        .select()
        .eq('id', id)
        .single();
    
    return SubjectModel.fromJson(response);
  }

  // Create a new subject
  Future<SubjectModel> createSubject(String name, String? code) async {
    final response = await supabase.from('subjects').insert({
      'name': name,
      'code': code,
    }).select().single();
    
    return SubjectModel.fromJson(response);
  }

  // Update a subject
  Future<SubjectModel> updateSubject(String id, String name, String? code) async {
    final response = await supabase.from('subjects').update({
      'name': name,
      'code': code,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id).select().single();
    
    return SubjectModel.fromJson(response);
  }

  // Delete a subject
  Future<void> deleteSubject(String id) async {
    await supabase.from('subjects').delete().eq('id', id);
  }
}