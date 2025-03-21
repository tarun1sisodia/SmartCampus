// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../models/class_model.dart';
// import '../services/database_service.dart';
// import '../providers/auth_provider.dart';
// import '../main.dart';

// class ClassProvider with ChangeNotifier {
//   final DatabaseService _databaseService;
  
//   List<ClassGroup> _classes = [];
//   ClassGroup? _selectedClass;
//   bool _isLoading = false;
//   String? _error;
  
//   // Filters for class selection
//   String? _selectedDegree;
//   int? _selectedYear;
//   String? _selectedSubject;
  
//   ClassProvider(this._databaseService);
  
//   // Getters
//   List<ClassGroup> get classes => _classes;
//   ClassGroup? get selectedClass => _selectedClass;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   String get errorMessage => _error ?? '';
  
//   String? get selectedDegree => _selectedDegree;
//   int? get selectedYear => _selectedYear;
//   String? get selectedSubject => _selectedSubject;
  
//   // Computed properties
//   bool get isDegreeSelected => _selectedDegree != null;
//   bool get isYearSelected => _selectedYear != null;
//   bool get isSubjectSelected => _selectedSubject != null;
//   bool get isClassSelected => _selectedClass != null;
  
//   // For class selection screen
//   List<String> get degrees => getAvailableDegrees();
//   List<String> get years => getAvailableYears().map((y) => y.toString()).toList();
//   List<String> get subjects => getAvailableSubjects();
  
//   // Load classes for a teacher
//   Future<void> loadClassesForTeacher(String teacherId) async {
//     _setLoading(true);
    
//     try {
//       _classes = await _databaseService.getClassesForTeacher(teacherId);
//       _setLoading(false);
//       notifyListeners();
//     } catch (e) {
//       _setError(e.toString());
//       _setLoading(false);
//     }
//   }
  
//   // Load degrees (used in class selection screen)
//   Future<void> loadDegrees() async {
//     _setLoading(true);
//     final authProvider = Provider.of<AuthProvider>(navigatorKey.currentContext!, listen: false);
    
//     try {
//       if (authProvider.user != null) {
//         await loadClassesForTeacher(authProvider.user!.uid);
//       } else {
//         _setError('User not authenticated');
//       }
//     } catch (e) {
//       _setError(e.toString());
//     } finally {
//       _setLoading(false);
//     }
//   }
  
//   // Select a class
//   void selectClass(ClassGroup classGroup) {
//     _selectedClass = classGroup;
//     notifyListeners();
//   }
  
//   // Clear selected class
//   void clearSelectedClass() {
//     _selectedClass = null;
//     notifyListeners();
//   }
  
//   // Add a new class
//   Future<bool> addClass(String degree, int year, String subject, String teacherId) async {
//     _setLoading(true);
    
//     try {
//       // Create a new class
//       final newClass = ClassGroup(
//         id: '', // This will be set by Firestore
//         degree: degree,
//         year: year,
//         subject: subject,
//         teacherId: teacherId,
//         studentIds: [], // Initially no students
//       );
      
//       // Add to Firestore
//       final classId = await _databaseService.addClass(newClass);
      
//       if (classId != null) {
//         // Add to local list with the ID
//         final classWithId = ClassGroup(
//           id: classId,
//           degree: degree,
//           year: year,
//           subject: subject,
//           teacherId: teacherId,
//           studentIds: [],
//         );
        
//         _classes.add(classWithId);
//         _setLoading(false);
//         notifyListeners();
//         return true;
//       } else {
//         _setError('Failed to add class.');
//         _setLoading(false);
//         return false;
//       }
//     } catch (e) {
//       _setError(e.toString());
//       _setLoading(false);
//       return false;
//     }
//   }
  
//   // Update a class
//   Future<bool> updateClass(ClassGroup updatedClass) async {
//     _setLoading(true);
    
//     try {
//       final success = await _databaseService.updateClass(updatedClass);
      
//       if (success) {
//         // Update in local list
//         final index = _classes.indexWhere((c) => c.id == updatedClass.id);
//         if (index != -1) {
//           _classes[index] = updatedClass;
          
//           // Update selected class if it's the one being updated
//           if (_selectedClass?.id == updatedClass.id) {
//             _selectedClass = updatedClass;
//           }
//         }
        
//         _setLoading(false);
//         notifyListeners();
//         return true;
//       } else {
//         _setError('Failed to update class.');
//         _setLoading(false);
//         return false;
//       }
//     } catch (e) {
//       _setError(e.toString());
//       _setLoading(false);
//       return false;
//     }
//   }
  
//   // Set filters for class selection
//   void setDegreeFilter(String? degree) {
//     _selectedDegree = degree;
//     notifyListeners();
//   }
  
//   void setYearFilter(int? year) {
//     _selectedYear = year;
//     notifyListeners();
//   }
  
//   void setSubjectFilter(String? subject) {
//     _selectedSubject = subject;
//     notifyListeners();
//   }
  
//   // Methods required by class_selection_screen
//   void selectDegree(String degree) {
//     _selectedDegree = degree;
//     // Clear subsequent selections
//     _selectedYear = null;
//     _selectedSubject = null;
//     notifyListeners();
//   }
  
//   void selectYear(String yearStr) {
//     _selectedYear = int.tryParse(yearStr);
//     // Clear subsequent selections
//     _selectedSubject = null;
//     notifyListeners();
//   }
  
//   void selectSubject(String subject) {
//     _selectedSubject = subject;
    
//     // Try to find a matching class with the current selections
//     if (_selectedDegree != null && _selectedYear != null && _selectedSubject != null) {
//       final matchingClasses = _classes.where((c) => 
//         c.degree == _selectedDegree && 
//         c.year == _selectedYear && 
//         c.subject == _selectedSubject
//       ).toList();
      
//       if (matchingClasses.isNotEmpty) {
//         _selectedClass = matchingClasses.first;
//       }
//     }
    
//     notifyListeners();
//   }
  
//   // Clear all filters
//   void clearFilters() {
//     _selectedDegree = null;
//     _selectedYear = null;
//     _selectedSubject = null;
//     notifyListeners();
//   }
  
//   // Get filtered classes
//   List<ClassGroup> getFilteredClasses() {
//     if (_selectedDegree == null && _selectedYear == null && _selectedSubject == null) {
//       return _classes;
//     }
    
//     return _classes.where((classGroup) {
//       bool matchesDegree = _selectedDegree == null || 
//                          classGroup.degree == _selectedDegree;
      
//       bool matchesYear = _selectedYear == null || 
//                         classGroup.year == _selectedYear;
      
//       bool matchesSubject = _selectedSubject == null || 
//                            classGroup.subject == _selectedSubject;
      
//       return matchesDegree && matchesYear && matchesSubject;
//     }).toList();
//   }
  
//   // Get unique degrees from available classes
//   List<String> getAvailableDegrees() {
//     final degrees = _classes.map((c) => c.degree).toSet().toList();
//     degrees.sort();
//     return degrees;
//   }
  
//   // Get unique years from available classes
//   List<int> getAvailableYears() {
//     final years = _classes.map((c) => c.year).toSet().toList();
//     years.sort();
//     return years;
//   }
  
//   // Get unique subjects from available classes
//   List<String> getAvailableSubjects() {
//     final subjects = _classes.map((c) => c.subject).toSet().toList();
//     subjects.sort();
//     return subjects;
//   }
  
//   // Helper methods
//   void _setLoading(bool isLoading) {
//     _isLoading = isLoading;
//     notifyListeners();
//   }
  
//   void _setError(String error) {
//     _error = error;
//     notifyListeners();
//   }
  
//   void _clearError() {
//     _error = null;
//     notifyListeners();
//   }
// }