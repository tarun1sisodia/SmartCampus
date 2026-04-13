import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../app/dependency_injection.dart';
import '../bloc/student_profile_bloc.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StudentProfileBloc>()..add(LoadStudentProfile(studentId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Student Profile')),
        body: BlocBuilder<StudentProfileBloc, StudentProfileState>(
          builder: (context, state) {
            if (state is StudentProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is StudentProfileError) {
              return Center(child: Text('Failed to load student profile: ${state.message}'));
            }
            if (state is! StudentProfileLoaded) {
              return const SizedBox.shrink();
            }

            final student = state.student;
            final summary = state.summary;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 42,
                      backgroundImage: student.photoUrl == null
                          ? null
                          : NetworkImage(student.photoUrl!),
                      child: student.photoUrl == null
                          ? const Icon(Icons.person, size: 42)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      student.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Center(
                    child: Text(
                      'Roll No: ${student.rollNumber}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: CircularPercentIndicator(
                      radius: 62,
                      lineWidth: 12,
                      percent: summary.presentPercentage.clamp(0, 1),
                      center: Text('${(summary.presentPercentage * 100).toStringAsFixed(0)}%'),
                      progressColor: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('Present', summary.presentCount, Colors.green),
                      _buildStat('Absent', summary.absentCount, Colors.red),
                      _buildStat('Late', summary.lateCount, Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoTile('Contact', student.contact ?? '-'),
                  _buildInfoTile('Parent Contact', student.parentContact ?? '-'),
                  _buildInfoTile('Course', student.course ?? '-'),
                  _buildInfoTile('Semester', student.semester?.toString() ?? '-'),
                  _buildInfoTile('Section', student.section ?? '-'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
