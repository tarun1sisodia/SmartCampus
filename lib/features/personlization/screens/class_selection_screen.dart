// import 'package:attedance__/features/authentication/providers/auth_provider.dart';
// import 'package:attedance__/features/personlization/screens/attendance_screen.dart';
// import 'package:attedance__/providers/class_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class ClassSelectionScreen extends StatefulWidget {
//   const ClassSelectionScreen({super.key});

//   @override
//   _ClassSelectionScreenState createState() => _ClassSelectionScreenState();
// }

// class _ClassSelectionScreenState extends State<ClassSelectionScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Load degrees on init
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<ClassProvider>(context, listen: false).loadDegrees();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Select Class'),
//       ),
//       body: Consumer<ClassProvider>(
//         builder: (context, classProvider, _) {
//           if (classProvider.isLoading) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }

//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Instructions
//                 _buildSectionTitle('Select Class Details'),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'Select the degree, year, and subject to take attendance for:',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//                 const SizedBox(height: 24),

//                 // Degree selection
//                 _buildSectionLabel('Degree'),
//                 const SizedBox(height: 8),
//                 _buildDegreeSelector(classProvider),
//                 const SizedBox(height: 24),

//                 // Year selection
//                 _buildSectionLabel('Year'),
//                 const SizedBox(height: 8),
//                 classProvider.isDegreeSelected
//                     ? _buildYearSelector(classProvider)
//                     : const Text(
//                         'Please select a degree first',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                 const SizedBox(height: 24),

//                 // Subject selection
//                 _buildSectionLabel('Subject'),
//                 const SizedBox(height: 8),
//                 classProvider.isYearSelected
//                     ? _buildSubjectSelector(classProvider)
//                     : const Text(
//                         'Please select a year first',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                 const SizedBox(height: 32),

//                 // Continue button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: classProvider.isClassSelected
//                         ? () => _navigateToAttendanceScreen(context)
//                         : null,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                     child: const Text(
//                       'Start Taking Attendance',
//                       style: TextStyle(fontSize: 16),
//                     ),
//                   ),
//                 ),

//                 if (classProvider.errorMessage.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 16.0),
//                     child: Text(
//                       classProvider.errorMessage,
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: const TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.bold,
//       ),
//     );
//   }

//   Widget _buildSectionLabel(String label) {
//     return Text(
//       label,
//       style: const TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.w500,
//       ),
//     );
//   }

//   Widget _buildDegreeSelector(ClassProvider classProvider) {
//     if (classProvider.degrees.isEmpty) {
//       return const Text(
//         'No degrees available',
//         style: TextStyle(color: Colors.red),
//       );
//     }

//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: ButtonTheme(
//           alignedDropdown: true,
//           child: DropdownButton<String>(
//             value: classProvider.selectedDegree,
//             isExpanded: true,
//             hint: const Text('Select Degree'),
//             items: classProvider.degrees.map((String degree) {
//               return DropdownMenuItem<String>(
//                 value: degree,
//                 child: Text(degree),
//               );
//             }).toList(),
//             onChanged: (value) {
//               if (value != null) {
//                 classProvider.selectDegree(value);
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildYearSelector(ClassProvider classProvider) {
//     if (classProvider.years.isEmpty) {
//       return const Text(
//         'No years available for selected degree',
//         style: TextStyle(color: Colors.red),
//       );
//     }

//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: ButtonTheme(
//           alignedDropdown: true,
//           child: DropdownButton<String>(
//             value: classProvider.selectedYear?.toString(),
//             isExpanded: true,
//             hint: const Text('Select Year'),
//             items: classProvider.years.map((String year) {
//               return DropdownMenuItem<String>(
//                 value: year,
//                 child: Text(year),
//               );
//             }).toList(),
//             onChanged: (value) {
//               if (value != null) {
//                 classProvider.selectYear(value);
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSubjectSelector(ClassProvider classProvider) {
//     if (classProvider.subjects.isEmpty) {
//       return const Text(
//         'No subjects available for selected degree and year',
//         style: TextStyle(color: Colors.red),
//       );
//     }

//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: ButtonTheme(
//           alignedDropdown: true,
//           child: DropdownButton<String>(
//             value: classProvider.selectedSubject,
//             isExpanded: true,
//             hint: const Text('Select Subject'),
//             items: classProvider.subjects.map((String subject) {
//               return DropdownMenuItem<String>(
//                 value: subject,
//                 child: Text(subject),
//               );
//             }).toList(),
//             onChanged: (value) {
//               if (value != null) {
//                 classProvider.selectSubject(value);
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   void _navigateToAttendanceScreen(BuildContext context) {
//     final classProvider = Provider.of<ClassProvider>(context, listen: false);
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
//     if (classProvider.selectedClass != null && authProvider.user != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => AttendanceScreen(
//             classGroup: classProvider.selectedClass!,
//             teacherId: authProvider.user!.uid,
//           ),
//         ),
//       );
//     }
//   }
// }
