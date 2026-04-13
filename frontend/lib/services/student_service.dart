import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:sentry_flutter/sentry_flutter.dart';

import '../models/student_model.dart';

class StudentService {
  final supabase = Supabase.instance.client;
  static const int defaultStudentsPerClassLimit = 200;

  // Get student counts for multiple classes (Batched)
  Future<Map<String, int>> getStudentCountsForClasses(List<String> classIds) async {
    try {
      if (classIds.isEmpty) return {};

      final counts = <String, int>{};
      await Future.wait<void>(classIds.map((id) async {
        final res = await supabase
            .from('class_students')
            .select()
            .eq('class_id', id)
            .count(CountOption.exact);
        counts[id] = res.count;
      }));

      return counts;
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      throw 'Failed to get student counts: $e';
    }
  }

  // Get all students for a class
  Future<List<StudentModel>> getStudentsForClass(
    String classId, {
    int limit = defaultStudentsPerClassLimit,
    int offset = 0,
  }) async {
    try {
      //print('Fetching students for class: $classId');
      final response = await supabase
          .from('class_students')
          .select(
            'class_id, created_at, students(id, name, roll_number, image_url, created_at, updated_at)',
          )
          .eq('class_id', classId)
          .range(offset, offset + limit - 1)
          .order('created_at');

      //print('Fetched students successfully: $response');
      return response.map<StudentModel>((json) {
        final studentData = json['students'] as Map<String, dynamic>;

        return StudentModel(
          id: studentData['id'],
          name: studentData['name'],
          rollNumber: studentData['roll_number'],
          imageUrl: studentData['image_url'], // this field
          classId: json['class_id'],
          createdAt: studentData['created_at'] != null
              ? DateTime.parse(studentData['created_at'])
              : null,
          updatedAt: studentData['updated_at'] != null
              ? DateTime.parse(studentData['updated_at'])
              : null,
        );
      }).toList();
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      //print('Failed to get students for class: $e');
      throw 'Failed to get students: $e';
    }
  }

  // add student to a class
  Future<void> addStudentToClass({
    required String name,
    required String rollNumber,
    required String classId,
    File? imageFile, // this parameter
  }) async {
    try {
      //print(
      // 'Adding student to class: $classId, Name: $name, Roll Number: $rollNumber');
      final existingStudents = await supabase
          .from('students')
          .select()
          .eq('roll_number', rollNumber);

      String studentId;
      String? imageUrl;

      // Upload image if provided
      if (imageFile != null) {
        final fileExt = path.extension(imageFile.path);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExt';
        final filePath = 'students/$rollNumber/$fileName';

        final response = await supabase.storage
            .from('student_images')
            .upload(filePath, imageFile);

        if (response.isNotEmpty) {
          // Get public URL for the uploaded image
          imageUrl =
              supabase.storage.from('student_images').getPublicUrl(filePath);

          //print('Uploaded student image: $imageUrl');
        }
      }

      if (existingStudents.isNotEmpty) {
        studentId = existingStudents[0]['id'];
        //print('Student exists with ID: $studentId');

        // student data if needed
        final updateData = <String, dynamic>{};
        if (existingStudents[0]['name'] != name) {
          updateData['name'] = name;
        }
        if (imageUrl != null && existingStudents[0]['image_url'] != imageUrl) {
          updateData['image_url'] = imageUrl;
        }

        if (updateData.isNotEmpty) {
          await supabase
              .from('students')
              .update(updateData)
              .eq('id', studentId);
          //print('Updated student data: $updateData');
        }
      } else {
        //Create a new student
        final studentData = {
          'name': name,
          'roll_number': rollNumber,
          'image_url': imageUrl,
          'created_at': DateTime.now().toIso8601String(),
        };

        final response = await supabase
            .from('students')
            .insert(studentData)
            .select()
            .single();

        studentId = response['id'];
        //print('Created new student with ID: $studentId');
      }
      // student to class if not already added
      final existingClassStudents = await supabase
          .from('class_students')
          .select()
          .eq('class_id', classId)
          .eq('student_id', studentId);

      if (existingClassStudents.isEmpty) {
        await supabase.from('class_students').insert({
          'class_id': classId,
          'student_id': studentId,
          'created_at': DateTime.now().toIso8601String(),
        });
        //print('Added student to class: $classId');
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      //print('Failed to add student to class: $e');
      throw 'Failed to add student to class: $e';
    }
  }

  // student image
  Future<String?> updateStudentImage({
    required String studentId,
    required File imageFile,
    required String rollNumber,
  }) async {
    try {
      //print('Updating image for student with ID: $studentId');

      final fileExt = path.extension(imageFile.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final filePath = 'students/$rollNumber/$fileName';

      final response = await supabase.storage
          .from('student_images')
          .upload(filePath, imageFile);

      if (response.isNotEmpty) {
        // Get public URL for the uploaded image
        final imageUrl =
            supabase.storage.from('student_images').getPublicUrl(filePath);

        // student record with new image URL
        await supabase
            .from('students')
            .update({'image_url': imageUrl}).eq('id', studentId);

        //print('Updated student image: $imageUrl');
        return imageUrl;
      }
      return null;
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      //print('Failed to update student image: $e');
      throw 'Failed to update student image: $e';
    }
  }

// Delete student image
  Future<void> deleteStudentImage({
    required String studentId,
    required String imageUrl,
  }) async {
    try {
      //print('Deleting image for student with ID: $studentId');

      // Extract the file path from the URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // The path should be something like 'storage/v1/object/public/student_images/students/rollNumber/filename'
      if (pathSegments.length >= 7) {
        final storagePath = pathSegments.sublist(4).join('/');

        // Delete the file from storage
        await supabase.storage.from('student_images').remove([storagePath]);

        // student record to remove image URL
        await supabase
            .from('students')
            .update({'image_url': null}).eq('id', studentId);

        //print('Deleted student image successfully');
      } else {
        throw 'Invalid image URL format';
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      //print('Failed to delete student image: $e');
      throw 'Failed to delete student image: $e';
    }
  }

  // Remove a student from a class
  Future<void> removeStudentFromClass({
    required String studentId,
    required String classId,
  }) async {
    try {
      //print('Removing student with ID: $studentId from class: $classId');
      await supabase
          .from('class_students')
          .delete()
          .eq('class_id', classId)
          .eq('student_id', studentId);

      //print('Removed student from class successfully');
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      //print('Failed to remove student from class: $e');
      throw 'Failed to remove student from class: $e';
    }
  }

  // Get a student by ID
  Future<StudentModel> getStudentById(String studentId) async {
    try {
      //print('Fetching student with ID: $studentId');
      final response =
          await supabase.from('students').select().eq('id', studentId).single();

      //print('Fetched student successfully: $response');
      return StudentModel(
        id: response['id'],
        name: response['name'],
        rollNumber: response['roll_number'],
        classId: '', // This will be filled in by the caller if needed
        createdAt: response['created_at'] != null
            ? DateTime.parse(response['created_at'])
            : null,
        updatedAt: response['updated_at'] != null
            ? DateTime.parse(response['updated_at'])
            : null,
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      //print('Failed to get student: $e');
      throw 'Failed to get student: $e';
    }
  }

  // Get all students
  Future<List<StudentModel>> getAllStudents() async {
    try {
      //print('Fetching all students');
      final response = await supabase.from('students').select().order('name');

      //print('Fetched all students successfully: $response');
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
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      //print('Failed to get all students: $e');
      throw 'Failed to get all students: $e';
    }
  }
}
