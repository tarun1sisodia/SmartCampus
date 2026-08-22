import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/dependency_injection.dart';
import '../bloc/qr_generator_bloc.dart';
import '../bloc/qr_generator_event.dart';
import '../bloc/qr_generator_state.dart';

class TeacherQrDisplayScreen extends StatelessWidget {
  final String sessionId;

  const TeacherQrDisplayScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<QrGeneratorBloc>()..add(StartQrGeneration(sessionId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Attendance QR Code'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Ask students to scan this QR code',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'This code refreshes every 15 seconds for security.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                BlocBuilder<QrGeneratorBloc, QrGeneratorState>(
                  builder: (context, state) {
                    if (state is QrGeneratorLoading) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 250,
                          height: 250,
                          color: Colors.white,
                        ),
                      );
                    } else if (state is QrGeneratorSuccess) {
                      // We encode token + sessionId as JSON or a custom string.
                      // For simplicity, we just pass the token. The student app needs both token and sessionId.
                      // So we'll combine them: "sessionId:token"
                      final qrData = '$sessionId:${state.token}';

                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromRGBO(0, 0, 0, 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: QrImageView(
                              data: qrData,
                              version: QrVersions.auto,
                              size: 250.0,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.timer, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'Refreshes in ${state.expiresIn}s',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else if (state is QrGeneratorFailure) {
                      return Column(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to generate QR:\n${state.message}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<QrGeneratorBloc>().add(StartQrGeneration(sessionId));
                            },
                            child: const Text('Retry'),
                          )
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
