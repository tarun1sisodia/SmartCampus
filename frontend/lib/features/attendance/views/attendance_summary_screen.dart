import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_campus/features/attendance/bloc/attendance_bloc.dart';
import 'package:smart_campus/features/attendance/models/attendance_record_model.dart';
import 'package:smart_campus/shared/widgets/network_image_with_placeholder.dart';

class AttendanceSummaryScreen extends StatelessWidget {
  final String sessionId;

  const AttendanceSummaryScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Summary', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AttendanceMarked) {
            final students = state.records;
            final present = students.where((s) => s.status == 'present').length;
            final absent = students.where((s) => s.status == 'absent').length;
            final late_ = students.where((s) => s.status == 'late').length;
            final pending = students.where((s) => s.status == 'pending').length;
            return _buildSummaryBody(context, students, present, absent, late_, pending);
          } else if (state is AttendanceLoaded) {
            final students = state.students;
            final present = students.where((s) => s.status == 'present').length;
            final absent = students.where((s) => s.status == 'absent').length;
            final late_ = students.where((s) => s.status == 'late').length;
            final pending = students.where((s) => s.status == 'pending').length;
            return _buildSummaryBody(context, students, present, absent, late_, pending);
          } else if (state is AttendanceError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No data found'));
        },
      ),
    );
  }

  Widget _buildSummaryBody(
    BuildContext context,
    List<AttendanceRecordModel> students,
    int present,
    int absent,
    int late_,
    int pending,
  ) {
    return Column(
      children: [
        _buildSummaryHeader(present, absent, late_, pending),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: students.length,
            itemBuilder: (context, index) => _buildStudentTile(students[index]),
          ),
        ),
        _buildBottomActions(context, pending),
      ],
    );
  }

  Widget _buildSummaryHeader(int present, int absent, int late_, int pending) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('PRESENT', present, Colors.green),
          _buildStatItem('ABSENT', absent, Colors.red),
          _buildStatItem('LATE', late_, Colors.orange),
          if (pending > 0) _buildStatItem('PENDING', pending, Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildStudentTile(AttendanceRecordModel student) {
    Color statusColor;
    switch (student.status) {
      case 'present': statusColor = Colors.green; break;
      case 'absent': statusColor = Colors.red; break;
      case 'late': statusColor = Colors.orange; break;
      default: statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: NetworkImageWithPlaceholder(
          imageUrl: student.photoUrl ?? 'https://via.placeholder.com/150',
          width: 40,
          height: 40,
          borderRadius: 20,
        ),
        title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(student.rollNumber ?? 'Roll No: N/A'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor),
          ),
          child: Text(
            student.status.toUpperCase(),
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, int pending) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
        ],
      ),
      child: Row(
        children: [
          if (pending > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.blue),
                ),
                child: const Text('BACK TO MARKING'),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // In a real app, this might trigger a 'finalize' API call.
                // For now, we return home.
                context.go('/home');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: pending > 0 ? Colors.grey : Colors.blue,
              ),
              child: Text(pending > 0 ? 'SUBMIT PARTIAL' : 'FINISH & SUBMIT'),
            ),
          ),
        ],
      ),
    );
  }
}
