// import 'package:attedance__/utils/constants/constants.dart';
// import 'package:flutter/material.dart';
// import '../models/student_model.dart';

// class StudentCard extends StatelessWidget {
//   final Student student;
//   final bool showSwipeInstructions;
//   final bool showBottomBar;
  
//   const StudentCard({
//     super.key,
//     required this.student,
//     this.showSwipeInstructions = true,
//     this.showBottomBar = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 500,
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Student image
//           Expanded(
//             flex: 3,
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: student.imageUrl != null && student.imageUrl!.isNotEmpty
//                   ? Image.network(
//                       student.imageUrl!,
//                       fit: BoxFit.cover,
//                       width: double.infinity,
//                       height: double.infinity,
//                       errorBuilder: (context, error, stackTrace) {
//                         return _buildProfilePlaceholder();
//                       },
//                     )
//                   : _buildProfilePlaceholder(),
//             ),
//           ),
          
//           const SizedBox(height: 16),
          
//           // Student details
//           Expanded(
//             flex: 2,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Name with roll number
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         student.name,
//                         style: const TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColors.primary.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         student.rollNumber,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.primary,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
                
//                 const SizedBox(height: 12),
                
//                 // Course details
//                 _buildDetailRow(
//                   Icons.school,
//                   student.course,
//                 ),
                
//                 const SizedBox(height: 8),
                
//                 // Year details
//                 _buildDetailRow(
//                   Icons.calendar_today,
//                   'Year ${student.year}',
//                 ),
                
//                 if (showSwipeInstructions) ...[
//                   const SizedBox(height: 20),
                  
//                   // Swipe instructions
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: Colors.grey.shade300,
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.swipe,
//                           color: Colors.grey.shade600,
//                           size: 16,
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Swipe right for present, left for absent',
//                           style: TextStyle(
//                             color: Colors.grey.shade600,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfilePlaceholder() {
//     return Container(
//       color: Colors.grey.shade300,
//       child: Center(
//         child: Icon(
//           Icons.person,
//           size: 80,
//           color: Colors.grey.shade400,
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(IconData icon, String text) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           size: 18,
//           color: Colors.grey.shade600,
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             text,
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey.shade800,
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
// }