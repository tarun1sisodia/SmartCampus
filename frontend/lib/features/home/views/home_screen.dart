import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/home_bloc.dart';
import '../widgets/stats_overview.dart';
import '../widgets/session_card.dart';
import '../../../shared/widgets/shimmer_loading.dart';
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
    context.read<HomeBloc>().add(const LoadTodaySessions());
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
            onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return _buildShimmerState();
          } else if (state is HomeError) {
            return shared.ErrorWidget(
              message: state.message,
              onRetry: () => context.read<HomeBloc>().add(const LoadTodaySessions()),
            );
          } else if (state is HomeLoaded) {
            final totalStudents = state.sessions.fold<int>(
              0,
              (sum, session) => sum + session.totalStudents,
            );
            final avgAttendance = state.sessions.isEmpty
                ? 0.0
                : state.sessions
                        .map((s) {
                          if (s.totalStudents == 0 || s.presentCount == null) return 0.0;
                          return s.presentCount! / s.totalStudents;
                        })
                        .reduce((a, b) => a + b) /
                    state.sessions.length;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(const LoadTodaySessions());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  StatsOverview(
                    totalClasses: state.sessions.length,
                    totalStudents: totalStudents,
                    averageAttendance: avgAttendance,
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
                        onPressed: () => context.push('/history'),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state.sessions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).colorScheme.outline),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.event_busy, size: 36),
                          SizedBox(height: 12),
                          Text(
                            'No sessions scheduled for today',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Pull down to refresh or check session history.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/attendance/qr/scan'),
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan QR'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildShimmerState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ShimmerLoading(width: double.infinity, height: 170, borderRadius: 8),
        SizedBox(height: 24),
        ShimmerLoading(width: 160, height: 24, borderRadius: 4),
        SizedBox(height: 16),
        ShimmerLoading(width: double.infinity, height: 100, borderRadius: 4),
        SizedBox(height: 12),
        ShimmerLoading(width: double.infinity, height: 100, borderRadius: 4),
        SizedBox(height: 12),
        ShimmerLoading(width: double.infinity, height: 100, borderRadius: 4),
      ],
    );
  }
}
