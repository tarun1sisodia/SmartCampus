import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/home_bloc.dart';
import 'widgets/stats_overview.dart';
import 'widgets/session_card.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_widget.dart' as shared;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<HomeBloc>().add(HomeLoadRequested(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartCampus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const LoadingIndicator(message: 'Loading dashboard...');
          } else if (state is HomeError) {
            return shared.ErrorWidget(
              message: state.message,
              onRetry: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context.read<HomeBloc>().add(HomeLoadRequested(authState.user.id));
                }
              },
            );
          } else if (state is HomeLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                 final authState = context.read<AuthBloc>().state;
                 if (authState is AuthAuthenticated) {
                   context.read<HomeBloc>().add(HomeLoadRequested(authState.user.id));
                 }
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const StatsOverview(
                    totalClasses: 4,
                    totalStudents: 120,
                    averageAttendance: 0.85,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today's Sessions",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => context.push('/sessions/history'),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state.sessions.isEmpty)
                    const Center(child: Text('No sessions scheduled for today'))
                  else
                    ...state.sessions.map((session) => SessionCard(
                      session: session,
                      onTap: () => context.push('/session/${session.id}'),
                    )),
                ],
              ),
            );
          }
          return const Center(child: Text('Welcome!'));
        },
      ),
    );
  }
}
