// import 'package:attedance__/features/authentication/providers/auth_provider.dart';
// import 'package:attedance__/utils/constants/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:provider/provider.dart';

// import 'class_selection_screen.dart';
// import 'profile_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;
  
//   // Define screens for bottom navigation
//   late final List<Widget> _screens;
  
//   @override
//   void initState() {
//     super.initState();
//     _screens = [
//       _buildHomeContent(),
//       const ProfileScreen(),
//     ];
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Attendance Tracker'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () => _showLogoutDialog(context),
//           ),
//         ],
//       ),
//       body: _screens[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//         selectedItemColor: AppColors.primary,
//         elevation: 8,
//       ),
//     );
//   }

//   Widget _buildHomeContent() {
//     final authProvider = Provider.of<AuthProvider>(context);
//     final user = authProvider.user;

//     return SafeArea(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Welcome card
//             Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   children: [
//                     const CircleAvatar(
//                       radius: 30,
//                       backgroundColor: AppColors.primary,
//                       child: Icon(
//                         Icons.person,
//                         size: 32,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Welcome,',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[700],
//                             ),
//                           ),
//                           Text(
//                             user?.name ?? 'Teacher',
//                             style: const TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             user?.email ?? '',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
            
//             const SizedBox(height: 24),
//             const Text(
//               'Quick Actions',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
            
//             // Take attendance card
//             _buildActionCard(
//               context,
//               'Take Attendance',
//               'Mark students\' attendance by swiping',
//               Icons.how_to_reg,
//               Colors.blue.shade100,
//               Colors.blue,
//               () => Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ClassSelectionScreen(),
//                 ),
//               ),
//             ),
            
//             const SizedBox(height: 16),
            
//             // View records card
//             _buildActionCard(
//               context,
//               'View Records',
//               'Check previous attendance records',
//               Icons.history,
//               Colors.green.shade100,
//               Colors.green,
//               () {
//                 // To be implemented
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Coming soon!'),
//                   ),
//                 );
//               },
//             ),
            
//             const SizedBox(height: 16),
            
//             // Reports card
//             _buildActionCard(
//               context,
//               'Analytics & Reports',
//               'View attendance statistics',
//               Icons.bar_chart,
//               Colors.purple.shade100,
//               Colors.purple,
//               () {
//                 // To be implemented
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Coming soon!'),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionCard(
//     BuildContext context,
//     String title,
//     String subtitle,
//     IconData icon,
//     Color bgColor,
//     Color iconColor,
//     VoidCallback onTap,
//   ) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: bgColor,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   icon,
//                   size: 32,
//                   color: iconColor,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       subtitle,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const Icon(Icons.chevron_right),
//             ],
//           ),
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
