import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/attendance_bloc.dart';
import '../models/attendance_record_model.dart';
import 'widgets/student_carousel_card.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_widget.dart' as shared;

class CarouselAttendanceScreen extends StatefulWidget {
  final String sessionId;

  const CarouselAttendanceScreen({super.key, required this.sessionId});

  @override
  State<CarouselAttendanceScreen> createState() => _CarouselAttendanceScreenState();
}

class _CarouselAttendanceScreenState extends State<CarouselAttendanceScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final Map<String, String> _draftStatuses = {};

  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(LoadStudents(widget.sessionId));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: BlocBuilder<AttendanceBloc, AttendanceState>(
            builder: (context, state) {
              if (state is AttendanceLoaded) {
                final progress = state.students.isEmpty ? 0.0 : (state.markedCount / state.students.length);
                return LinearProgressIndicator(value: progress);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceOfflineSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AttendanceMarked) {
            if (mounted) {
              context.push('/attendance/summary/${widget.sessionId}');
            }
          } else if (state is AttendanceError) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const LoadingIndicator(message: 'Loading students...');
          } else if (state is AttendanceError && state is! AttendanceLoaded) {
            return shared.ErrorWidget(
              message: state.message,
              onRetry: () => context.read<AttendanceBloc>().add(LoadStudents(widget.sessionId)),
            );
          } else if (state is AttendanceLoaded) {
            if (state.students.isEmpty) {
              return const Center(child: Text('No students found for this session.'));
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Student ${_currentIndex + 1} of ${state.students.length}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentIndex = index),
                    itemCount: state.students.length,
                    itemBuilder: (context, index) {
                      final student = state.students[index];
                      final currentStatus = _draftStatuses[student.studentId] ?? student.status;
                      return StudentCarouselCard(
                        student: student.copyWith(status: currentStatus),
                        onStatusSelected: (status) {
                          setState(() {
                            _draftStatuses[student.studentId] = status;
                          });
                          // Auto move to next after a delay if not last
                          if (_currentIndex < state.students.length - 1) {
                            Future.delayed(const Duration(milliseconds: 300), () {
                              if (mounted) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            });
                          }
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _currentIndex > 0 
                            ? () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                            : null,
                        icon: const Icon(Icons.arrow_back_ios),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final records = state.students
                              .map((s) => s.copyWith(status: _draftStatuses[s.studentId] ?? s.status))
                              .toList();
                          context.read<AttendanceBloc>().add(
                                MarkAttendance(
                                  sessionId: widget.sessionId,
                                  records: records,
                                ),
                              );
                        },
                        child: const Text('SUBMIT ALL'),
                      ),
                      IconButton(
                        onPressed: _currentIndex < state.students.length - 1
                            ? () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                            : null,
                        icon: const Icon(Icons.arrow_forward_ios),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
