import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus/features/session/bloc/session_bloc.dart';
import 'package:smart_campus/features/session/bloc/session_event.dart';
import 'package:smart_campus/features/session/bloc/session_state.dart';
import 'package:smart_campus/features/home/views/widgets/session_card.dart';
import 'package:smart_campus/features/home/models/session_model.dart';
import 'package:smart_campus/features/auth/bloc/auth_bloc.dart';
import 'package:smart_campus/app/dependency_injection.dart';

class SessionHistoryScreen extends StatelessWidget {
  const SessionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final teacherId = authState is AuthAuthenticated ? authState.user.id : '';
    return BlocProvider(
      create: (context) => getIt<SessionBloc>()
        ..add(SessionHistoryRequested(teacherId: teacherId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Session History',
              style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
        ),
        body: BlocBuilder<SessionBloc, SessionState>(
          builder: (context, state) {
            if (state is SessionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SessionHistoryLoaded) {
              if (state.sessions.isEmpty) {
                return const Center(child: Text('No sessions found'));
              }

              final grouped = <String, List<SessionModel>>{};
              for (final session in state.sessions) {
                final key =
                    DateFormat('EEEE, MMM d, yyyy').format(session.startTime);
                grouped.putIfAbsent(key, () => []).add(session);
              }
              final dates = grouped.keys.toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  final dateKey = dates[index];
                  final sessions = grouped[dateKey]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 12),
                        child: Text(
                          dateKey.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      ...sessions.map(
                        (session) => SessionCard(
                          session: session,
                          onTap: () => context.push('/session/${session.id}'),
                        ),
                      ),
                    ],
                  );
                },
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
}
