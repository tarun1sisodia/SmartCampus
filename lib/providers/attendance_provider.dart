// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/student_model.dart';
// import '../models/class_model.dart';
// import '../models/attendance_model.dart';
// import '../services/database_service.dart';

// class AttendanceProvider with ChangeNotifier {
//   final DatabaseService _databaseService;
  
//   List<Student> _students = [];
//   Map<String, bool> _attendanceStatus = {}; // studentId -> isPresent
//   bool _isLoading = false;
//   bool _isSubmitting = false;
//   String _errorMessage = '';
//   final DateTime _attendanceDate = DateTime.now();
//   Student? _currentStudent;
//   AttendanceModel? _currentAttendance;
//   bool _isAttendanceComplete = false;
//   ClassGroup? _currentClass;
  
//   AttendanceProvider(this._databaseService);
  
//   // Getters
//   List<Student> get students => _students;
//   Map<String, bool> get attendanceStatus => _attendanceStatus;
//   bool get isLoading => _isLoading;
//   bool get isSubmitting => _isSubmitting;
//   String get errorMessage => _errorMessage;
//   Student? get currentStudent => _currentStudent;
//   bool get isAttendanceComplete => _isAttendanceComplete;
//   AttendanceModel? get currentAttendance => _currentAttendance;
//   ClassGroup? get currentClass => _currentClass;
  
//   // Get number of students processed
//   int get processedStudents => _attendanceStatus.length;
  
//   // Get total number of students 
//   int get totalStudents => _students.length;
  
//   // Get progress percentage for UI display
//   double get progressPercentage => 
//     totalStudents > 0 ? processedStudents / totalStudents : 0.0;
  
//   // Get formatted date for display
//   String get formattedDate => DateFormat('EEEE, MMMM d, yyyy').format(_attendanceDate);
  
//   // Get unprocessed students (those whose attendance hasn't been marked yet)
//   List<Student> get unprocessedStudents {
//     return _students.where((student) => 
//         !_attendanceStatus.containsKey(student.id)).toList();
//   }
  
//   // Get number of present students
//   int get presentCount {
//     return _attendanceStatus.values.where((isPresent) => isPresent).length;
//   }
  
//   // Get number of absent students
//   int get absentCount {
//     return _attendanceStatus.values.where((isPresent) => !isPresent).length;
//   }
  
//   // Load students for a class
//   Future<void> loadStudentsForClass(ClassGroup classGroup) async {
//     _setLoading(true);
//     _clearAttendanceStatus();
    
//     try {
//       _students = await _databaseService.getStudentsForClass(classGroup);
//       _setLoading(false);
//       notifyListeners();
//     } catch (e) {
//       _setError(e.toString());
//       _setLoading(false);
//     }
//   }
  
//   // Mark attendance for a student
//   void markAttendance(String studentId, bool isPresent) {
//     _attendanceStatus[studentId] = isPresent;
//     notifyListeners();
//   }
  
//   // Save attendance to Firestore
//   Future<bool> saveAttendance(String classId, String teacherId) async {
//     _setLoading(true);
    
//     try {
//       bool allSuccess = true;
      
//       // Save each student's attendance
//       // for (final entry in _attendanceStatus.entries) {
//       //   final success = await _databaseService.markAttendance(
//       //     classId, 
//       //     entry.key, 
//       //     entry.value, 
//       //     teacherId,
//       //   );
        
//       //   if (!success) {
//       //     allSuccess = false;
//       //   }
//       // }
      
//       _setLoading(false);
      
//       if (allSuccess) {
//         _clearAttendanceStatus();
//         notifyListeners();
//         return true;
//       } else {
//         _setError('Failed to save some attendance records.');
//         return false;
//       }
//     } catch (e) {
//       _setError(e.toString());
//       _setLoading(false);
//       return false;
//     }
//   }
  
//   // Check if attendance has been marked for a class on a specific date
//   Future<bool> isAttendanceMarked(ClassGroup classGroup) async {
//     _setLoading(true);
    
//     try {
//       final isMarked = await _databaseService.isAttendanceMarked(
//         classGroup, 
//         DateTime.now(),
//       );
      
//       _setLoading(false);
//       return isMarked;
//     } catch (e) {
//       _setError(e.toString());
//       _setLoading(false);
//       return false;
//     }
//   }
  
//   // Clear attendance status
//   void _clearAttendanceStatus() {
//     _attendanceStatus.clear();
//     notifyListeners();
//   }
  
//   // Initialize attendance for a class
//   Future<bool> initializeAttendance(ClassGroup classGroup, String teacherId) async {
//     _setLoading(true);
//     _clearError();
//     _currentClass = classGroup;
    
//     try {
//       // Load students
//       await loadStudentsForClass(classGroup);
      
//       if (_students.isEmpty) {
//         _setError('No students found in this class.');
//         _setLoading(false);
//         return false;
//       }
      
//       // Set current student to first student
//       _currentStudent = _students.first;
//       _isAttendanceComplete = false;
      
//       _setLoading(false);
//       return true;
//     } catch (e) {
//       _setError('Failed to initialize attendance: ${e.toString()}');
//       _setLoading(false);
//       return false;
//     }
//   }
  
//   // Mark current student as present
//   void markPresent() {
//     if (_currentStudent != null) {
//       markAttendance(_currentStudent!.id, true);
//       _moveToNextStudent();
//     }
//   }
  
//   // Mark current student as absent
//   void markAbsent() {
//     if (_currentStudent != null) {
//       markAttendance(_currentStudent!.id, false);
//       _moveToNextStudent();
//     }
//   }
  
//   // Move to the next student
//   void _moveToNextStudent() {
//     if (_currentStudent == null) return;
    
//     final unprocessed = unprocessedStudents;
//     if (unprocessed.isEmpty) {
//       // All students processed
//       _isAttendanceComplete = true;
//       _currentStudent = null;
      
//       // Create attendance record
//       final present = _students.where((s) => 
//         _attendanceStatus.containsKey(s.id) && _attendanceStatus[s.id]!).toList();
      
//       final absent = _students.where((s) => 
//         _attendanceStatus.containsKey(s.id) && !_attendanceStatus[s.id]!).toList();
      
//       _currentAttendance = AttendanceModel(
//         id: '',
//         classId: _currentClass?.id ?? '',
//         teacherId: '',
//         date: _attendanceDate,
//         presentStudents: present,
//         absentStudents: absent,
//       );
//     } else {
//       // Move to next unprocessed student
//       _currentStudent = unprocessed.first;
//     }
    
//     notifyListeners();
//   }
  
//   // Submit attendance to database
//   Future<bool> submitAttendance() async {
//     if (_currentAttendance == null || _currentClass == null) return false;
    
//     _isSubmitting = true;
//     notifyListeners();
    
//     try {
//       final success = await saveAttendance(_currentClass!.id, _currentAttendance!.teacherId);
      
//       _isSubmitting = false;
//       notifyListeners();
      
//       return success;
//     } catch (e) {
//       _setError('Failed to submit attendance: ${e.toString()}');
//       _isSubmitting = false;
//       notifyListeners();
//       return false;
//     }
//   }
  
//   // Reset the state
//   void resetState() {
//     _students = [];
//     _attendanceStatus = {};
//     _isLoading = false;
//     _isSubmitting = false;
//     _errorMessage = '';
//     _currentStudent = null;
//     _currentAttendance = null;
//     _isAttendanceComplete = false;
//     _currentClass = null;
//     notifyListeners();
//   }
  
//   // Helper methods
//   void _setLoading(bool isLoading) {
//     _isLoading = isLoading;
//     notifyListeners();
//   }
  
//   void _setError(String error) {
//     _errorMessage = error;
//     notifyListeners();
//   }
  
//   void _clearError() {
//     _errorMessage = '';
//     notifyListeners();
//   }
// }