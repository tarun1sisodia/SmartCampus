
// import 'student_model.dart';

// // Individual student attendance record
// class Attendance {
//   final String id;
//   final String classId;
//   final String studentId;
//   final DateTime date;
//   final bool isPresent;
//   final String markedById; // Teacher ID who marked attendance

//   Attendance({
//     required this.id,
//     required this.classId,
//     required this.studentId,
//     required this.date,
//     required this.isPresent,
//     required this.markedById,
//   });

//   // Factory constructor to create Attendance from a Map (Firestore document)
//   factory Attendance.fromMap(Map<String, dynamic> map, String documentId) {
//     return Attendance(
//       id: documentId,
//       classId: map['classId'] ?? '',
//       studentId: map['studentId'] ?? '',
//       date: (map['date'] != null) 
//           ? (map['date'] as Timestamp).toDate() 
//           : DateTime.now(),
//       isPresent: map['isPresent'] ?? false,
//       markedById: map['markedById'] ?? '',
//     );
//   }

//   // Convert Attendance to a Map for Firestore
//   Map<String, dynamic> toMap() {
//     return {
//       'classId': classId,
//       'studentId': studentId,
//       'date': Timestamp.fromDate(date),
//       'isPresent': isPresent,
//       'markedById': markedById,
//     };
//   }
// }

// // Aggregated attendance model for a class
// class AttendanceModel {
//   final String id;
//   final String classId;
//   final String teacherId;
//   final DateTime date;
//   final List<Student> presentStudents;
//   final List<Student> absentStudents;

//   AttendanceModel({
//     required this.id,
//     required this.classId,
//     required this.teacherId,
//     required this.date,
//     required this.presentStudents,
//     required this.absentStudents,
//   });

//   // Calculate the attendance percentage
//   double get attendancePercentage {
//     int totalStudents = presentStudents.length + absentStudents.length;
//     if (totalStudents == 0) return 0.0;
//     return (presentStudents.length / totalStudents) * 100;
//   }

//   // Get total students count
//   int get totalStudents {
//     return presentStudents.length + absentStudents.length;
//   }

//   // Factory constructor to create AttendanceModel from a Map (Firestore document)
//   factory AttendanceModel.fromMap(Map<String, dynamic> map, String documentId, 
//       List<Student> allStudents) {
    
//     // Convert student IDs to Student objects
//     List<String> presentIds = List<String>.from(map['presentStudents'] ?? []);
//     List<String> absentIds = List<String>.from(map['absentStudents'] ?? []);
    
//     List<Student> present = allStudents
//         .where((student) => presentIds.contains(student.id))
//         .toList();
    
//     List<Student> absent = allStudents
//         .where((student) => absentIds.contains(student.id))
//         .toList();
    
//     return AttendanceModel(
//       id: documentId,
//       classId: map['classId'] ?? '',
//       teacherId: map['teacherId'] ?? '',
//       date: (map['date'] != null) 
//           ? (map['date'] as Timestamp).toDate() 
//           : DateTime.now(),
//       presentStudents: present,
//       absentStudents: absent,
//     );
//   }

//   // Convert AttendanceModel to a Map for Firestore
//   Map<String, dynamic> toMap() {
//     // Extract student IDs
//     List<String> presentIds = presentStudents.map((s) => s.id).toList();
//     List<String> absentIds = absentStudents.map((s) => s.id).toList();
    
//     return {
//       'classId': classId,
//       'teacherId': teacherId,
//       'date': Timestamp.fromDate(date),
//       'presentStudents': presentIds,
//       'absentStudents': absentIds,
//       'totalCount': totalStudents,
//       'presentCount': presentStudents.length,
//       'absentCount': absentStudents.length,
//       'attendancePercentage': attendancePercentage,
//     };
//   }
// }