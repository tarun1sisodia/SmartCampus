// import 'package:attedance__/models/class_model.dart';
// import 'package:attedance__/providers/attendance_provider.dart';
// import 'package:attedance__/utils/constants/constants.dart';
// import 'package:attedance__/widgets/swipeable_card.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class AttendanceScreen extends StatefulWidget {
//   final ClassGroup classGroup;
//   final String teacherId;

//   const AttendanceScreen({
//     super.key,
//     required this.classGroup,
//     required this.teacherId,
//   });

//   @override
//   _AttendanceScreenState createState() => _AttendanceScreenState();
// }

// class _AttendanceScreenState extends State<AttendanceScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Initialize attendance
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeAttendance();
//     });
//   }

//   Future<void> _initializeAttendance() async {
//     final attendanceProvider = 
//         Provider.of<AttendanceProvider>(context, listen: false);
    
//     bool success = await attendanceProvider.initializeAttendance(
//       widget.classGroup,
//       widget.teacherId,
//     );

//     if (!success && mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(attendanceProvider.errorMessage),
//           backgroundColor: Colors.red,
//         ),
//       );
//       // Go back if initialization fails
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Take Attendance'),
//         ),
//         body: Consumer<AttendanceProvider>(
//           builder: (context, attendanceProvider, _) {
//             if (attendanceProvider.isLoading) {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             }

//             // Show complete screen if attendance is completed
//             if (attendanceProvider.isAttendanceComplete) {
//               return _buildCompletionScreen(attendanceProvider);
//             }

//             // Show error if there is one
//             if (attendanceProvider.errorMessage.isNotEmpty) {
//               return Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(
//                         Icons.error_outline,
//                         color: Colors.red,
//                         size: 48,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         attendanceProvider.errorMessage,
//                         style: const TextStyle(color: Colors.red, fontSize: 16),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 24),
//                       ElevatedButton(
//                         onPressed: () => Navigator.pop(context),
//                         child: const Text('Go Back'),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }

//             return Column(
//               children: [
//                 // Header info
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   color: Colors.grey.shade100,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         '${widget.classGroup}',
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Date: ${attendanceProvider.formattedDate}',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Progress indicator
//                 LinearProgressIndicator(
//                   value: attendanceProvider.progressPercentage,
//                   backgroundColor: Colors.grey.shade200,
//                   valueColor: const AlwaysStoppedAnimation<Color>(
//                     AppColors.primary,
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Progress: ${attendanceProvider.processedStudents}/${attendanceProvider.totalStudents}',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       Text(
//                         '${(attendanceProvider.progressPercentage * 100).toStringAsFixed(1)}%',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Instructions
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Row(
//                     children: [
//                       _buildInstructionBox(
//                         Icons.arrow_back,
//                         Colors.red,
//                         'Swipe left to mark absent',
//                       ),
//                       const SizedBox(width: 16),
//                       _buildInstructionBox(
//                         Icons.arrow_forward,
//                         Colors.green,
//                         'Swipe right to mark present',
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Student card
//                 if (attendanceProvider.currentStudent != null)
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: SwipeableCard(
//                         student: attendanceProvider.currentStudent!,
//                         onSwipeLeft: () => attendanceProvider.markAbsent(),
//                         onSwipeRight: () => attendanceProvider.markPresent(),
//                       ),
//                     ),
//                   ),

//                 // Manual buttons (for accessibility)
//                 if (attendanceProvider.currentStudent != null)
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: () => attendanceProvider.markAbsent(),
//                             icon: const Icon(Icons.close),
//                             label: const Text('Absent'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.red,
//                               foregroundColor: Colors.white,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: () => attendanceProvider.markPresent(),
//                             icon: const Icon(Icons.check),
//                             label: const Text('Present'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.green,
//                               foregroundColor: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildInstructionBox(IconData icon, Color color, String text) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(8.0),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: color.withOpacity(0.5)),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: color, size: 20),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 text,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: color.withOpacity(0.8),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCompletionScreen(AttendanceProvider attendanceProvider) {
//     return Padding(
//       padding: const EdgeInsets.all(24.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.check_circle_outline,
//             color: Colors.green,
//             size: 64,
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'Attendance Complete!',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'You have successfully marked attendance for all ${attendanceProvider.totalStudents} students.',
//             style: const TextStyle(fontSize: 16),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Present: ${attendanceProvider.currentAttendance?.presentStudents.length ?? 0}\nAbsent: ${attendanceProvider.currentAttendance?.absentStudents.length ?? 0}',
//             style: const TextStyle(fontSize: 16),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 32),
//           attendanceProvider.isSubmitting
//               ? const CircularProgressIndicator()
//               : ElevatedButton.icon(
//                   onPressed: () => _submitAttendance(attendanceProvider),
//                   icon: const Icon(Icons.save),
//                   label: const Text('Save Attendance'),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 12,
//                     ),
//                   ),
//                 ),
//         ],
//       ),
//     );
//   }

//   Future<void> _submitAttendance(AttendanceProvider attendanceProvider) async {
//     bool success = await attendanceProvider.submitAttendance();

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             success
//                 ? 'Attendance saved successfully!'
//                 : 'Failed to save attendance: ${attendanceProvider.errorMessage}',
//           ),
//           backgroundColor: success ? Colors.green : Colors.red,
//         ),
//       );

//       if (success) {
//         attendanceProvider.resetState();
//         Navigator.pop(context);
//       }
//     }
//   }

//   Future<bool> _onWillPop() async {
//     final attendanceProvider = 
//         Provider.of<AttendanceProvider>(context, listen: false);
    
//     // Don't show dialog if attendance is complete or there was an error
//     if (attendanceProvider.isAttendanceComplete || 
//         attendanceProvider.errorMessage.isNotEmpty) {
//       return true;
//     }

//     // Show confirmation dialog if in the middle of attendance
//     if (attendanceProvider.processedStudents > 0) {
//       return await showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Discard Attendance?'),
//           content: const Text(
//             'You have not finished marking attendance. If you go back now, all progress will be lost.'
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: const Text('CANCEL'),
//             ),
//             TextButton(
//               onPressed: () {
//                 attendanceProvider.resetState();
//                 Navigator.of(context).pop(true);
//               },
//               child: const Text('DISCARD'),
//             ),
//           ],
//         ),
//       ) ?? false;
//     }

//     return true;
//   }
// }
