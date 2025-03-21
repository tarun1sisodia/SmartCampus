// import 'package:intl/intl.dart';
// import '../models/student_model.dart';
// import '../models/attendance_model.dart';
// import '../models/class_model.dart';

// // Simplified database service with mock data for initial development
// class DatabaseService {
//   // Mock data for development and testing
//   final Map<String, List<String>> _degreesWithYears = {
//     'Computer Science': ['1st Year', '2nd Year', '3rd Year', '4th Year'],
//     'Electrical Engineering': ['1st Year', '2nd Year', '3rd Year', '4th Year'],
//     'Mechanical Engineering': ['1st Year', '2nd Year', '3rd Year', '4th Year'],
//   };
  
//   final Map<String, Map<String, List<String>>> _subjectsByDegreeAndYear = {
//     'Computer Science': {
//       '1st Year': ['Programming Fundamentals', 'Calculus', 'Digital Logic Design'],
//       '2nd Year': ['Data Structures', 'Computer Architecture', 'Database Systems'],
//       '3rd Year': ['Operating Systems', 'Computer Networks', 'Software Engineering'],
//       '4th Year': ['Artificial Intelligence', 'Machine Learning', 'Computer Vision'],
//     },
//     'Electrical Engineering': {
//       '1st Year': ['Circuit Theory', 'Engineering Mathematics', 'Physics'],
//       '2nd Year': ['Electromagnetic Theory', 'Signals and Systems', 'Digital Electronics'],
//       '3rd Year': ['Control Systems', 'Communication Systems', 'Power Electronics'],
//       '4th Year': ['Power Systems', 'Digital Signal Processing', 'Renewable Energy'],
//     },
//     'Mechanical Engineering': {
//       '1st Year': ['Engineering Mechanics', 'Thermodynamics', 'Materials Science'],
//       '2nd Year': ['Fluid Mechanics', 'Manufacturing Processes', 'Kinematics'],
//       '3rd Year': ['Heat Transfer', 'Machine Design', 'Vibrations'],
//       '4th Year': ['Robotics', 'Automotive Engineering', 'CAD/CAM'],
//     },
//   };
  
//   // Mock student data
//   final Map<String, List<StudentModel>> _studentsByClass = {};

//   // Store attendance data
//   final Map<String, AttendanceModel> _attendanceRecords = {};
  
//   // Constructor to initialize mock student data
//   DatabaseService() {
//     _initializeStudentData();
//   }
  
//   // Initialize student data with mock data
//   void _initializeStudentData() {
//     // Generate students for each class
//     _degreesWithYears.forEach((degree, years) {
//       for (var year in years) {
//         _subjectsByDegreeAndYear[degree]?[year]?.forEach((subject) {
//           String classKey = '${degree}_${year}_$subject';
//           List<StudentModel> students = List.generate(
//             15, // 15 students per class
//             (index) => StudentModel(
//               id: 'student_${degree.substring(0, 3).toLowerCase()}_${year.substring(0, 1)}_${index + 1}',
//               name: 'Student ${index + 1}',
//               rollNumber: '${year.substring(0, 1)}${index.toString().padLeft(3, '0')}',
//               degree: degree,
//               year: year,
//               imageUrl: 'https://ui-avatars.com/api/?name=Student+${index + 1}&background=random',
//             ),
//           );
//           _studentsByClass[classKey] = students;
//         });
//       }
//     });
//   }

//   // Get all degrees
//   Future<List<String>> getAllDegrees() async {
//     // Simulate network delay
//     await Future.delayed(const Duration(milliseconds: 300));
//     return _degreesWithYears.keys.toList();
//   }

//   // Get years for a specific degree
//   Future<List<String>> getYearsForDegree(String degree) async {
//     // Simulate network delay
//     await Future.delayed(const Duration(milliseconds: 300));
//     return _degreesWithYears[degree] ?? [];
//   }

//   // Get subjects for a specific degree and year
//   Future<List<String>> getSubjectsForDegreeAndYear(
//       String degree, String year) async {
//     // Simulate network delay
//     await Future.delayed(const Duration(milliseconds: 300));
//     return _subjectsByDegreeAndYear[degree]?[year] ?? [];
//   }

//   // Get students for a specific class (degree, year, subject)
//   Future<List<StudentModel>> getStudentsForClass(ClassModel classModel) async {
//     // Simulate network delay
//     await Future.delayed(const Duration(milliseconds: 500));
    
//     String classKey = '${classModel.degree}_${classModel.year}_${classModel.subject}';
//     return _studentsByClass[classKey] ?? [];
//   }

//   // Save attendance record
//   Future<bool> saveAttendance(AttendanceModel attendance) async {
//     try {
//       // Simulate network delay
//       await Future.delayed(const Duration(milliseconds: 700));
      
//       // Format date as YYYY-MM-DD for document ID
//       String dateString = DateFormat('yyyy-MM-dd').format(attendance.date);
      
//       // Create document path for this specific class and date
//       String docPath = 
//           '${attendance.classModel.degree}_${attendance.classModel.year}_${attendance.classModel.subject}_$dateString';
      
//       // Save attendance record to mock data store
//       _attendanceRecords[docPath] = attendance;
      
//       return true;
//     } catch (e) {
//       print('Error saving attendance: $e');
//       return false;
//     }
//   }

//   // Check if attendance has already been marked for a class on a specific date
//   Future<bool> isAttendanceMarked(ClassModel classModel, DateTime date) async {
//     // Simulate network delay
//     await Future.delayed(const Duration(milliseconds: 300));
    
//     String dateString = DateFormat('yyyy-MM-dd').format(date);
//     String docPath = 
//         '${classModel.degree}_${classModel.year}_${classModel.subject}_$dateString';
    
//     return _attendanceRecords.containsKey(docPath);
//   }

//   // Get attendance record for a specific class on a specific date
//   Future<AttendanceModel?> getAttendanceRecord(
//       ClassModel classModel, DateTime date) async {
//     // Simulate network delay
//     await Future.delayed(const Duration(milliseconds: 500));
    
//     String dateString = DateFormat('yyyy-MM-dd').format(date);
//     String docPath = 
//         '${classModel.degree}_${classModel.year}_${classModel.subject}_$dateString';
    
//     return _attendanceRecords[docPath];
//   }
// }
