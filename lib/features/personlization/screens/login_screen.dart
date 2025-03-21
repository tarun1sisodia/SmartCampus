// import 'package:attedance__/features/authentication/providers/auth_provider.dart';
// import 'package:attedance__/utils/constants/constants.dart';
// import 'package:attedance__/utils/constants/validators.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoginMode = true;
//   bool _isLoading = false;
//   bool _obscurePassword = true;
//   String _name = '';

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _switchAuthMode() {
//     setState(() {
//       _isLoginMode = !_isLoginMode;
//       // No need to manually clear errors when switching modes
//     });
//   }

//   void _togglePasswordVisibility() {
//     setState(() {
//       _obscurePassword = !_obscurePassword;
//     });
//   }

//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     _formKey.currentState!.save();
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);

//     if (_isLoginMode) {
//       // Login
//       final success = await authProvider.signInWithEmailAndPassword(
//         _emailController.text.trim(),
//         _passwordController.text,
//       );

//       if (!success && mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(authProvider.error ?? 'Failed to sign in'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } else {
//       // Register
//       final success = await authProvider.registerWithEmailAndPassword(
//         _emailController.text.trim(),
//         _passwordController.text,
//         _name.trim(),
//       );

//       if (!success && mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(authProvider.error ?? 'Failed to register'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);

//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // App logo and title
//               Column(
//                 children: [
//                   Icon(
//                     Icons.school,
//                     size: 80,
//                     color: AppColors.primary,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Attendance Tracker',
//                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                           color: AppColors.primary,
//                           fontWeight: FontWeight.bold,
//                         ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     _isLoginMode
//                         ? 'Sign in to your account'
//                         : 'Create a new account',
//                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                           color: Colors.grey[600],
//                         ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 40),

//               // Auth form
//               Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // Name field (only for register mode)
//                     if (!_isLoginMode)
//                       TextFormField(
//                         decoration: const InputDecoration(
//                           labelText: 'Name',
//                           prefixIcon: Icon(Icons.person),
//                         ),
//                         textInputAction: TextInputAction.next,
//                         validator: Validators.validateName,
//                         onSaved: (value) => _name = value ?? '',
//                       ),
//                     if (!_isLoginMode) const SizedBox(height: 16),

//                     // Email field
//                     TextFormField(
//                       controller: _emailController,
//                       decoration: const InputDecoration(
//                         labelText: 'Email',
//                         prefixIcon: Icon(Icons.email),
//                       ),
//                       keyboardType: TextInputType.emailAddress,
//                       textInputAction: TextInputAction.next,
//                       validator: Validators.validateEmail,
//                     ),
//                     const SizedBox(height: 16),

//                     // Password field
//                     TextFormField(
//                       controller: _passwordController,
//                       decoration: InputDecoration(
//                         labelText: 'Password',
//                         prefixIcon: const Icon(Icons.lock),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscurePassword
//                                 ? Icons.visibility
//                                 : Icons.visibility_off,
//                           ),
//                           onPressed: _togglePasswordVisibility,
//                         ),
//                       ),
//                       obscureText: _obscurePassword,
//                       textInputAction: _isLoginMode
//                           ? TextInputAction.done
//                           : TextInputAction.next,
//                       validator: Validators.validatePassword,
//                     ),
//                     const SizedBox(height: 24),

//                     // Submit button
//                     ElevatedButton(
//                       onPressed: authProvider.isLoading ? null : _submitForm,
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                       ),
//                       child: authProvider.isLoading
//                           ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                           : Text(
//                               _isLoginMode ? 'SIGN IN' : 'REGISTER',
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                     ),
//                     const SizedBox(height: 16),

//                     // Forgot password button (only for login mode)
//                     if (_isLoginMode)
//                       TextButton(
//                         onPressed: () {
//                           // To be implemented
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text('Coming soon!'),
//                             ),
//                           );
//                         },
//                         child: const Text('Forgot password?'),
//                       ),

//                     // Switch auth mode button
//                     TextButton(
//                       onPressed: _switchAuthMode,
//                       child: Text(
//                         _isLoginMode
//                             ? 'Don\'t have an account? Register'
//                             : 'Already have an account? Sign in',
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }