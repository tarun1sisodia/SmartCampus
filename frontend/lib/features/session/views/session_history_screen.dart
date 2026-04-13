import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_campus/features/session/bloc/session_bloc.dart';
import 'package:smart_campus/features/session/bloc/session_event.dart';
import 'package:smart_campus/features/session/bloc/session_state.dart';
import 'package:smart_campus/features/home/views/widgets/session_card.dart';
import 'package:smart_campus/app/dependency_injection.dart';

class SessionHistoryScreen extends StatelessWidget {
  const SessionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SessionBloc>()..add(SessionHistoryRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Session History', style: TextStyle(fontWeight: FontWeight.bold)),
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
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.sessions.length,
                itemBuilder: (context, index) {
                  final session = state.sessions[index];
                  return SessionCard(
                    session: session,
                    onTap: () => context.push('/session/${session.id}'),
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
