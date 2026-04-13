import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:smart_campus/features/analytics/models/teacher_stats_model.dart';
import '../bloc/analytics_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import 'widgets/attendance_percentage_chart.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_widget.dart' as shared;

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String? _teacherId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _teacherId = authState.user.id;
      final now = DateTime.now();
      context.read<AnalyticsBloc>().add(
            LoadStats(
              teacherId: authState.user.id,
              range: DateTimeRange(
                start: now.subtract(const Duration(days: 7)),
                end: now,
              ),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Performance Analytics')),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return const LoadingIndicator(message: 'Loading statistics...');
          } else if (state is AnalyticsError) {
            return shared.ErrorWidget(
              message: state.message,
              onRetry: () {
                if (_teacherId != null) {
                  final now = DateTime.now();
                  context.read<AnalyticsBloc>().add(
                        LoadStats(
                          teacherId: _teacherId!,
                          range: DateTimeRange(
                            start: now.subtract(const Duration(days: 7)),
                            end: now,
                          ),
                        ),
                      );
                }
              },
            );
          } else if (state is AnalyticsLoaded) {
            final stats = state.stats;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRangeSelector(context, state.range),
                  const SizedBox(height: 24),
                  Center(
                    child: CircularPercentIndicator(
                      radius: 80.0,
                      lineWidth: 15.0,
                      percent: stats.overallAttendance,
                      center: Text(
                        "${(stats.overallAttendance * 100).toInt()}%",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                      ),
                      footer: const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                          "Overall Attendance",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: Colors.blue,
                      animation: true,
                    ),
                  ),
                  const SizedBox(height: 48),
                  const Text(
                    "Subject-wise Attendance",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  AttendancePercentageChart(subjectStats: stats.subjectBreakdown),
                  const SizedBox(height: 48),
                  const Text(
                    "Subject Details",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...stats.subjectBreakdown.map((subject) => _buildSubjectRow(subject)),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSubjectRow(SubjectStats subject) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(subject.subjectName, style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              SizedBox(
                width: 100,
                child: LinearProgressIndicator(
                  value: subject.attendance,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(_getColor(subject.attendance)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "${(subject.attendance * 100).toInt()}%",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColor(double percent) {
    if (percent >= 0.8) return Colors.green;
    if (percent >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Widget _buildRangeSelector(BuildContext context, DateTimeRange currentRange) {
    Future<void> loadRange(DateTimeRange range) async {
      if (_teacherId == null) return;
      context.read<AnalyticsBloc>().add(LoadStats(teacherId: _teacherId!, range: range));
    }

    final now = DateTime.now();
    final last7 = DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now);
    final thisMonth = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: const Text('Last 7 days'),
          selected: _isSameRange(currentRange, last7),
          onSelected: (_) => loadRange(last7),
        ),
        ChoiceChip(
          label: const Text('This month'),
          selected: _isSameRange(currentRange, thisMonth),
          onSelected: (_) => loadRange(thisMonth),
        ),
        ActionChip(
          label: const Text('Custom'),
          onPressed: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(now.year - 1),
              lastDate: now,
              initialDateRange: currentRange,
            );
            if (picked != null) {
              await loadRange(picked);
            }
          },
        ),
      ],
    );
  }

  bool _isSameRange(DateTimeRange a, DateTimeRange b) {
    return a.start.year == b.start.year &&
        a.start.month == b.start.month &&
        a.start.day == b.start.day &&
        a.end.year == b.end.year &&
        a.end.month == b.end.month &&
        a.end.day == b.end.day;
  }
}
