import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_campus/features/session/bloc/session_bloc.dart';
import 'package:smart_campus/features/session/bloc/session_event.dart';
import 'package:smart_campus/features/session/bloc/session_state.dart';
import 'package:smart_campus/app/dependency_injection.dart';
import 'package:smart_campus/shared/widgets/network_image_with_placeholder.dart';
import '../../../common/utils/constants/colors.dart';

class SessionDetailScreen extends StatelessWidget {
  final String sessionId;

  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SessionBloc>()..add(SessionDetailsRequested(sessionId)),
      child: Scaffold(
        backgroundColor: TColors.slate50,
        appBar: AppBar(
          title: const Text('SESSION DETAILS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.0)),
          elevation: 0,
        ),
        body: BlocBuilder<SessionBloc, SessionState>(
          builder: (context, state) {
            if (state is SessionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SessionDetailsLoaded) {
              final session = state.sessionDetail;
              final startTime = DateFormat('EEEE, MMM d • hh:mm a').format(session.startTime).toUpperCase();
              
              return Column(
                children: [
                  _builderHeader(session, startTime),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push('/attendance/$sessionId'),
                        child: const Text('MARK ATTENDANCE'),
                      ),
                    ),
                  ),
                  const Divider(height: 1.5, thickness: 1.5),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'STUDENTS (${session.attendanceRecords.length})',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.0, color: TColors.slate600),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF10B981), width: 1.0),
                          ),
                          child: Text(
                            'PRESENT: ${session.presentCount ?? 0}',
                            style: const TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.w900, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: session.attendanceRecords.length,
                      itemBuilder: (context, index) {
                        final record = session.attendanceRecords[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: TColors.slate400, width: 1.5),
                          ),
                          child: ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: TColors.executiveNavy, width: 1.5),
                              ),
                              child: NetworkImageWithPlaceholder(
                                imageUrl: record.photoUrl ?? 'https://via.placeholder.com/150',
                                width: 44,
                                height: 44,
                                borderRadius: 4,
                              ),
                            ),
                            title: GestureDetector(
                              onTap: () => context.push('/student/${record.studentId}'),
                              child: Text(record.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: TColors.slate900)),
                            ),
                            subtitle: Text((record.rollNumber ?? 'N/A').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: TColors.slate600)),
                            trailing: _buildStatusChip(record.status),
                            onTap: () => context.push('/student/${record.studentId}'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else if (state is SessionError) {
              return Center(child: Text('ERROR: ${state.message.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w800, color: TColors.error)));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _builderHeader(dynamic session, String time) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (session.subjectName as String).toUpperCase(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: TColors.slate900, letterSpacing: -0.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.event_note, size: 16, color: TColors.slate600),
              const SizedBox(width: 8),
              Text(time, style: const TextStyle(color: TColors.slate600, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 16, color: TColors.slate600),
              const SizedBox(width: 8),
              Text('STATUS: ${session.status.toUpperCase()}', 
                style: TextStyle(
                  color: _getStatusColor(session.status),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.5,
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
    Color bgColor;
    switch (status.toLowerCase()) {
      case 'present': color = const Color(0xFF065F46); bgColor = const Color(0xFFECFDF5); break;
      case 'absent': color = const Color(0xFF9F1239); bgColor = const Color(0xFFFFF1F2); break;
      case 'late': color = const Color(0xFF92400E); bgColor = const Color(0xFFFFFBEB); break;
      default: color = TColors.slate600; bgColor = TColors.slate100;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: color, width: 1.0),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 9),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return const Color(0xFF059669);
      case 'ongoing': return TColors.executiveNavy;
      case 'scheduled': return const Color(0xFFD97706);
      default: return TColors.slate600;
    }
  }
}
