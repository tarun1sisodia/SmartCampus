import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/utils/constants/constants.dart';
import '../controllers/session_details_controller.dart';

class SessionDetailsScreen extends StatelessWidget {
  final SessionDetailsController controller =
      Get.put(SessionDetailsController());

  SessionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Safely get arguments with null checks
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;

    // If arguments are null, show an error state
    if (args == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('SESSION ERROR', style: TextStyle(fontWeight: FontWeight.w900)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.danger, size: 48, color: TColors.error),
              const SizedBox(height: 24),
              const Text(
                'SESSION INFORMATION MISSING',
                style: TextStyle(fontSize: 14, color: TColors.slate600, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('RETURN TO DASHBOARD'),
              ),
            ],
          ),
        ),
      );
    }

    final String sessionId = args['sessionId'];
    final Map<String, dynamic> classDetails = args['classDetails'];

    return Scaffold(
      backgroundColor: TColors.slate50,
      appBar: AppBar(
        title: const Text('SESSION DETAILS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.0)),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: () => controller.refreshData(sessionId),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.session.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.search_status, size: 48, color: TColors.slate400),
                const SizedBox(height: 24),
                const Text(
                  'SESSION RECORD NOT FOUND',
                  style: TextStyle(fontSize: 14, color: TColors.slate600, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('GO BACK'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSessionHeader(classDetails),
              const SizedBox(height: 24),
              _buildSessionInfo(),
              const SizedBox(height: 24),
              _buildAttendanceStats(),
              const SizedBox(height: 24),
              _buildAttendanceActions(),
              const SizedBox(height: 24),
              _buildStudentsList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSessionHeader(Map<String, dynamic> classDetails) {
    return Container(
      decoration: BoxDecoration(
        color: TColors.executiveNavy,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (classDetails['subjectName'] ?? 'UNKNOWN SUBJECT').toUpperCase(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildHeaderRow(Iconsax.teacher, classDetails['courseName'] ?? 'UNKNOWN COURSE'),
          const SizedBox(height: 8),
          _buildHeaderRow(Iconsax.calendar, 'SEMESTER ${classDetails['semester'] ?? 'N/A'}'),
          const SizedBox(height: 8),
          _buildHeaderRow(Iconsax.hierarchy, 'SECTION ${classDetails['section'] ?? 'A'}'),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 12),
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildSessionInfo() {
    final session = controller.session.value!;
    final isActive = controller.isSessionActive();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isActive ? const Color(0xFF10B981) : TColors.slate400,
          width: isActive ? 2.5 : 1.5,
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SESSION LOGS',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: TColors.slate900, letterSpacing: 1.0),
              ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.rectangle)),
                      const SizedBox(width: 8),
                      const Text(
                        'LIVE',
                        style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.w900, fontSize: 10),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow(Iconsax.calendar_1, 'DATE', controller.formatDate(session.date).toUpperCase()),
          const SizedBox(height: 16),
          _buildInfoRow(Iconsax.clock, 'TIME WINDOW', '${session.startTime ?? "N/A"} - ${session.endTime ?? "N/A"}'.toUpperCase()),
          const SizedBox(height: 16),
          _buildInfoRow(Iconsax.location, 'FACILITY', 'PROFESSOR OFFICE / RM 104'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: TColors.slate400),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: TColors.slate500, letterSpacing: 0.5)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: TColors.slate900)),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceStats() {
    return Obx(() {
      final stats = controller.attendanceStats.value;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: TColors.slate400, width: 1.5),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ATTENDANCE PERFORMANCE',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: TColors.slate900, letterSpacing: 1.0),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('ENROLLED', stats.total.toString(), TColors.executiveNavy),
                _buildStatItem('PRESENT', stats.present.toString(), const Color(0xFF10B981)),
                _buildStatItem('ABSENT', stats.absent.toString(), const Color(0xFFF43F5E)),
              ],
            ),
            const SizedBox(height: 32),
            Stack(
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  color: TColors.slate100,
                ),
                FractionallySizedBox(
                  widthFactor: stats.presentPercentage / 100,
                  child: Container(
                    height: 12,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('CUMULATIVE RATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: TColors.slate500)),
                Text(
                  '${stats.presentPercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color, letterSpacing: -1.0),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: TColors.slate500, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildAttendanceActions() {
    final isActive = controller.isSessionActive();

    return Container(
      decoration: BoxDecoration(
        color: TColors.slate100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: TColors.slate400, width: 1.5),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ADMINISTRATIVE CONTROLS',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: TColors.slate900, letterSpacing: 1.0),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Iconsax.mask),
                  label: const Text('GENERATE QR'),
                  onPressed: isActive ? () => controller.generateQRCode() : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Iconsax.document_download),
                  label: const Text('EXPORT CSV'),
                  onPressed: () => controller.exportAttendanceData(),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: TColors.slate400, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Iconsax.edit_2),
              label: const Text('OVERRIDE ATTENDANCE'),
              onPressed: isActive ? () => controller.openManualAttendance() : null,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: TColors.slate400, width: 1.5),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'NOMINAL ROLL',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: TColors.slate900, letterSpacing: 1.0),
              ),
              IconButton(
                icon: const Icon(Iconsax.search_normal_1, color: TColors.executiveNavy),
                onPressed: () => controller.searchStudents(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.attendanceRecords.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Iconsax.people, size: 48, color: TColors.slate300),
                      const SizedBox(height: 16),
                      const Text(
                        'NO DATA FOUND',
                        style: TextStyle(color: TColors.slate500, fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.attendanceRecords.length,
              separatorBuilder: (context, index) => const Divider(height: 1.5, thickness: 1.5),
              itemBuilder: (context, index) {
                final record = controller.attendanceRecords[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: record.isPresent ? const Color(0xFFECFDF5) : const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: record.isPresent ? const Color(0xFF10B981) : const Color(0xFFF43F5E), width: 1.5),
                    ),
                    child: Icon(
                      record.isPresent ? Iconsax.user_tick : Iconsax.user_remove,
                      color: record.isPresent ? const Color(0xFF065F46) : const Color(0xFF9F1239),
                      size: 18,
                    ),
                  ),
                  title: Text(
                    record.studentName.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: TColors.slate900),
                  ),
                  subtitle: Text(
                    'ID: ${record.studentId}'.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: TColors.slate500),
                  ),
                  trailing: controller.isSessionActive()
                      ? Switch(
                          value: record.isPresent,
                          onChanged: (value) => controller.toggleAttendance(record.id, value),
                          activeColor: const Color(0xFF10B981),
                          activeTrackColor: const Color(0xFFECFDF5),
                        )
                      : null,
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
