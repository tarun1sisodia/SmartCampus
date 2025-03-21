// import 'package:attedance__/features/authentication/providers/auth_provider.dart';
// import 'package:attedance__/utils/constants/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
//     final user = authProvider.user;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Profile'),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Profile header
//               Center(
//                 child: Column(
//                   children: [
//                     const CircleAvatar(
//                       radius: 50,
//                       backgroundColor: AppColors.primary,
//                       child: Icon(
//                         Icons.person,
//                         size: 60,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       user?.name ?? 'Teacher',
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       user?.email ?? '',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColors.primary.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Text(
//                         user?.role ?? 'Teacher',
//                         style: TextStyle(
//                           color: AppColors.primary,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
              
//               const SizedBox(height: 32),
//               const Text(
//                 'Account Information',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               // Profile settings list
//               _buildProfileCard(
//                 'Personal Information',
//                 'Name, contact information',
//                 Icons.person_outline,
//                 () {},
//               ),
//               _buildProfileCard(
//                 'Preferences',
//                 'App settings, theme, notifications',
//                 Icons.settings_outlined,
//                 () {},
//               ),
//               _buildProfileCard(
//                 'Help & Support',
//                 'FAQs, contact support',
//                 Icons.help_outline,
//                 () {},
//               ),
//               _buildProfileCard(
//                 'Log Out',
//                 'Sign out from your account',
//                 Icons.logout,
//                 () => _showLogoutDialog(context),
//                 isLogout: true,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileCard(
//     String title,
//     String subtitle,
//     IconData icon,
//     VoidCallback onTap, {
//     bool isLogout = false,
//   }) {
//     return Card(
//       elevation: 0,
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(
//           color: Colors.grey.shade200,
//         ),
//       ),
//       child: ListTile(
//         onTap: onTap,
//         leading: Icon(
//           icon,
//           color: isLogout ? Colors.red : AppColors.primary,
//         ),
//         title: Text(
//           title,
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: isLogout ? Colors.red : Colors.black,
//           ),
//         ),
//         subtitle: Text(subtitle),
//         trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 8,
//         ),
//       ),
//     );
//   }

//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Log Out'),
//         content: const Text('Are you sure you want to log out?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('CANCEL'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Provider.of<AuthProvider>(context, listen: false).signOut();
//             },
//             child: const Text('LOG OUT'),
//           ),
//         ],
//       ),
//     );
//   }
// }