import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../../shared/widgets/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   CircleAvatar(
                     radius: 60,
                     backgroundColor: Colors.blue.withOpacity(0.1),
                     child: const Icon(Icons.person, size: 80, color: Colors.blue),
                   ),
                   const SizedBox(height: 24),
                   Text(
                     user.name,
                     style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 8),
                   Text(
                     user.email,
                     style: const TextStyle(fontSize: 16, color: Colors.grey),
                   ),
                   const SizedBox(height: 16),
                   Chip(label: Text(user.role.toUpperCase())),
                   const Spacer(),
                   CustomButton(
                     text: 'LOGOUT',
                     color: Colors.red,
                     onPressed: () {
                       context.read<AuthBloc>().add(AuthLogoutRequested());
                     },
                   ),
                   const SizedBox(height: 32),
                ],
              ),
            );
          }
          return const Center(child: Text('Please login to view profile'));
        },
      ),
    );
  }
}
