
import '../utils/constants/constants.dart';
import 'package:flutter/material.dart';
// import '../providers/connectivity_provider.dart';

class NoConnectionScreen extends StatelessWidget {
  const NoConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Network error icon
              Icon(
                Icons.signal_wifi_off,
                size: 80,
                color: AppColors.error,
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                'No Internet Connection',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Description
              Text(
                'Please check your internet connection and try again. '
                'This app requires an active internet connection to work properly.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Retry button
              // ElevatedButton.icon(
              //   onPressed: () {
              //     // Check connectivity again
              //     Provider.of<ConnectivityProvider>(context, listen: false)
              //       .checkConnectivity();
              //   },
              //   icon: const Icon(Icons.refresh),
              //   label: const Text('Try Again'),
              //   style: ElevatedButton.styleFrom(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 24,
              //       vertical: 12,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}