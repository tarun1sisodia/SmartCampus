import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/utils/constants/constants.dart';
import '../controllers/session_details_controller.dart';

class SessionDetailsScreen extends StatelessWidget {
  final SessionDetailsController controller =
      Get.put(SessionDetailsController());

  SessionDetailsScreen({super.key}) {
    //print('SessionDetailsScreen constructor called');
  }

  @override
  Widget build(BuildContext context) {
    // Safely get arguments with null checks
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;

    // If arguments are null, show an error state
    if (args == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Session Details'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Session information not provided',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final String sessionId = args['sessionId'];
    final Map<String, dynamic> classDetails = args['classDetails'];

    //print('Building SessionDetailsScreen for session ID: $sessionId');
    return Scaffold(
      appBar: AppBar(
        title: Text('Session Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              //print('Refresh button pressed');
              controller.refreshData(sessionId);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.session.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Session not found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text('Go Back'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSessionHeader(classDetails),
              SizedBox(height: 24),
              _buildSessionInfo(),
              SizedBox(height: 24),
              _buildAttendanceStats(),
              SizedBox(height: 24),
              _buildAttendanceActions(),
              SizedBox(height: 24),
              _buildStudentsList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSessionHeader(Map<String, dynamic> classDetails) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              classDetails['subjectName'] ?? 'Unknown Subject',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: TColors.primary,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.school, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  classDetails['courseName'] ?? 'Unknown Course',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Semester ${classDetails['semester'] ?? 'Unknown'}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.group, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Section ${classDetails['section'] ?? 'Unknown'}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfo() {
    final session = controller.session.value!;
    final isActive = controller.isSessionActive();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive
            ? BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Session Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isActive)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.date_range, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Date: ${controller.formatDate(session.date)}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Time: ${session.startTime ?? 'N/A'} - ${session.endTime ?? 'N/A'}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Room: Not specified', // Since room isn't in the model
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.note, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Notes: No notes for this session', // Since notes isn't in the model
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceStats() {
    return Obx(() {
      final attendanceStats = controller.attendanceStats.value;

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Attendance Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Total', attendanceStats.total.toString(),
                      TColors.primary),
                  _buildStatItem('Present', attendanceStats.present.toString(),
                      Colors.green),
                  _buildStatItem(
                      'Absent', attendanceStats.absent.toString(), Colors.red),
                ],
              ),
              SizedBox(height: 16),
              LinearProgressIndicator(
                value: attendanceStats.presentPercentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              SizedBox(height: 8),
              Text(
                'Attendance Rate: ${attendanceStats.presentPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceActions() {
    final isActive = controller.isSessionActive();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.qr_code),
                    label: Text('Generate QR Code'),
                    onPressed: isActive
                        ? () {
                            controller.generateQRCode();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.download),
                    label: Text('Export Data'),
                    onPressed: () {
                      controller.exportAttendanceData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(Icons.edit),
              label: Text('Manual Attendance'),
              onPressed: isActive
                  ? () {
                      controller.openManualAttendance();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                minimumSize: Size(double.infinity, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            if (!isActive)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Note: Some actions are only available during active sessions',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Student Attendance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    controller.searchStudents();
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            Obx(() {
              if (controller.attendanceRecords.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.people_outline,
                            size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No attendance records yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.attendanceRecords.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final record = controller.attendanceRecords[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: record.isPresent
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      child: Icon(
                        record.isPresent ? Icons.check : Icons.close,
                        color: record.isPresent ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      record.studentName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Student ID: ${record.studentId}'),
                    trailing: controller.isSessionActive()
                        ? Switch(
                            value: record.isPresent,
                            onChanged: (value) {
                              controller.toggleAttendance(record.id, value);
                            },
                            activeColor: Colors.green,
                          )
                        : null,
                  );
                },
              );
            }),
            SizedBox(height: 16),
            Obx(() => controller.attendanceRecords.isNotEmpty
                ? OutlinedButton(
                    onPressed: () {
                      controller.viewAllStudents();
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      side: BorderSide(color: TColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('View All Students'),
                  )
                : SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
