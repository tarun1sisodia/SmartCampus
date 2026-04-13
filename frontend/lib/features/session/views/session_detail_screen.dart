import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus/features/session/bloc/session_bloc.dart';
import 'package:smart_campus/features/session/bloc/session_event.dart';
import 'package:smart_campus/features/session/bloc/session_state.dart';
import 'package:smart_campus/app/dependency_injection.dart';
import 'package:smart_campus/shared/widgets/network_image_with_placeholder.dart';

class SessionDetailScreen extends StatelessWidget {
  final String sessionId;

  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SessionBloc>()..add(SessionDetailsRequested(sessionId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Session Details', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
        ),
        body: BlocBuilder<SessionBloc, SessionState>(
          builder: (context, state) {
            if (state is SessionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SessionDetailsLoaded) {
              final session = state.sessionDetail;
              final startTime = DateFormat('EEEE, MMM d • hh:mm a').format(session.startTime);
              
              return Column(
                children: [
                  _builderHeader(session, startTime),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Students (${session.attendanceRecords.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Present: ${session.presentCount ?? 0}',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: session.attendanceRecords.length,
                      itemBuilder: (context, index) {
                        final record = session.attendanceRecords[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: ListTile(
                            leading: NetworkImageWithPlaceholder(
                              imageUrl: record.photoUrl ?? 'https://via.placeholder.com/150',
                              width: 40,
                              height: 40,
                              borderRadius: 20,
                            ),
                            title: Text(record.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(record.rollNumber ?? 'N/A'),
                            trailing: _buildStatusChip(record.status),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else if (state is SessionError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _builderHeader(dynamic session, String time) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            session.subjectName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.event, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(time, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.label_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text('Status: ${session.status.toUpperCase()}', 
                style: TextStyle(
                  color: _getStatusColor(session.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'present': color = Colors.green; break;
      case 'absent': color = Colors.red; break;
      case 'late': color = Colors.orange; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'ongoing': return Colors.blue;
      case 'scheduled': return Colors.orange;
      default: return Colors.grey;
    }
  }
}
