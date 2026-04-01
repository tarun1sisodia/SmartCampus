import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/student_detail_controller.dart';
import '../../../../models/student_model.dart';
import '../../../../../common/utils/constants/api_constants.dart';

class StudentDetailCorporate extends StatelessWidget {
  final StudentDetailController controller;
  final StudentModel student;

  const StudentDetailCorporate({super.key, required this.controller, required this.student});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.industrialCorporate);

    return Container(
      color: const Color(0xFFF1F5F9),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)));
        }

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildCorporateProfileHeader(context),
            const SizedBox(height: 32),
            const Text('PERFORMANCE_METRICS_HUD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            _buildCorporateStatsHUD(),
            const SizedBox(height: 48),
            const Text('HISTORICAL_LEDGER_STREAM', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            _buildCorporateHistoryStream(context),
            const SizedBox(height: 64),
          ],
        );
      }),
    );
  }

  Widget _buildCorporateProfileHeader(BuildContext context) {
    final currentStudent = controller.student.value;
    final hasImage = currentStudent?.imageUrl != null && currentStudent!.imageUrl!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFF0F172A), width: 2.5), boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.1), offset: const Offset(4, 4))]),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showImageOptions(context),
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), border: Border.all(color: const Color(0xFF0F172A), width: 1.5)),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: hasImage 
                       ? CachedNetworkImage(imageUrl: ApiConstants.optimizeImageUrl(currentStudent!.imageUrl!, width: 160, height: 160), fit: BoxFit.cover)
                       : const Icon(Iconsax.user, color: Color(0xFF0F172A), size: 32),
                  ),
                  Positioned(right: 4, bottom: 4, child: Container(padding: const EdgeInsets.all(4), color: const Color(0xFF0F172A), child: const Icon(Iconsax.camera, color: Colors.white, size: 12))),
                  if (controller.isImageUploading.value) Positioned.fill(child: Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator(color: Colors.white)))),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(currentStudent?.name.toUpperCase() ?? student.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A), letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text('ROLL_NODE: ${currentStudent?.rollNumber ?? student.rollNumber}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF64748B))),
                if (controller.classModel.value != null) ...[
                   const SizedBox(height: 8),
                   Text('${controller.classModel.value!.subjectName} | SEM_${controller.classModel.value!.semester}'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Color(0xFF0F172A))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorporateStatsHUD() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
               _buildCorporateStatNode('FULFILLMENT', '${controller.attendancePercentage.value.toStringAsFixed(1)}%', const Color(0xFF0F172A)),
               _buildCorporateStatNode('SESSIONS', '${controller.totalSessions}', const Color(0xFF64748B)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
               _buildCorporateStatNode('PRESENT', '${controller.presentCount}', Colors.green),
               _buildCorporateStatNode('ABSENT', '${controller.absentCount}', Colors.red),
               _buildCorporateStatNode('LATE', '${controller.lateCount}', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCorporateStatNode(String label, String val, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: color, letterSpacing: -1)),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildCorporateHistoryStream(BuildContext context) {
    if (controller.attendanceHistory.isEmpty) {
      return Container(padding: const EdgeInsets.all(32), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0))), child: const Center(child: Text('LOG_STREAM_VOID', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), fontSize: 11))));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.attendanceHistory.length,
      itemBuilder: (context, index) {
        final record = controller.attendanceHistory[index];
        final session = record['session'];
        final status = record['status'] as String;
        final color = _getStatusColor(status);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0))),
          child: ListTile(
             onTap: () => _showUpdateStatusDialog(context, session.id, status, record['remarks']),
             contentPadding: const EdgeInsets.all(16),
             leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), border: Border.all(color: color, width: 2)), child: Center(child: Icon(_getStatusIcon(status), color: color, size: 20))),
             title: Text(DateFormat('yyyy_MM_dd').format(session.date).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A), fontFamily: 'Courier')),
             subtitle: Text('${session.startTime} > ${session.endTime}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Color(0xFF64748B), fontFamily: 'Courier')),
             trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), color: color, child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 9))),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present': return Colors.green;
      case 'absent': return Colors.red;
      case 'late': return Colors.orange;
      case 'excused': return Colors.blue;
      default: return const Color(0xFF0F172A);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'present': return Iconsax.verify;
      case 'absent': return Iconsax.close_circle;
      case 'late': return Iconsax.clock;
      case 'excused': return Iconsax.document;
      default: return Iconsax.message_question;
    }
  }

  void _showImageOptions(BuildContext context) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('PROFILE_IMAGE_MGMT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        const SizedBox(height: 20),
        ListTile(leading: const Icon(Iconsax.camera), title: const Text('CAMERA_CAPTURE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)), onTap: () { Get.back(); controller.pickImage(ImageSource.camera).then((_) { if(controller.selectedImage.value != null) controller.updateStudentImage(); }); }),
        ListTile(leading: const Icon(Iconsax.gallery), title: const Text('STORAGE_IMPORT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)), onTap: () { Get.back(); controller.pickImage(ImageSource.gallery).then((_) { if(controller.selectedImage.value != null) controller.updateStudentImage(); }); }),
      ]),
    ));
  }

  void _showUpdateStatusDialog(BuildContext context, String sessionId, String currentStatus, String? currentRemarks) {
     final remarksController = TextEditingController(text: currentRemarks);
     final selectedStatus = currentStatus.obs;

     Get.dialog(AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: Color(0xFF0F172A), width: 2.5)),
        title: const Text('MOD_ATTENDANCE_RECORD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
           Obx(() => Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _buildStatusBtn('PRESENT', Iconsax.verify, Colors.green, selectedStatus.value == 'present', () => selectedStatus.value = 'present'),
              _buildStatusBtn('ABSENT', Iconsax.close_circle, Colors.red, selectedStatus.value == 'absent', () => selectedStatus.value = 'absent'),
              _buildStatusBtn('LATE', Iconsax.clock, Colors.orange, selectedStatus.value == 'late', () => selectedStatus.value = 'late'),
           ])),
           const SizedBox(height: 24),
           TextField(controller: remarksController, decoration: const InputDecoration(labelText: 'REMARKS_NODE', border: OutlineInputBorder(borderRadius: BorderRadius.zero))),
        ]),
        actions: [
           TextButton(onPressed: () => Get.back(), child: const Text('TERMINATE')),
           ElevatedButton(onPressed: () { controller.updateAttendanceRecord(sessionId: sessionId, status: selectedStatus.value, remarks: remarksController.text.isEmpty ? null : remarksController.text); Get.back(); }, child: const Text('EXECUTE')),
        ],
     ));
  }

  Widget _buildStatusBtn(String label, IconData icon, Color color, bool isSelected, VoidCallback onTap) {
     return InkWell(
        onTap: onTap,
        child: Container(
           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
           decoration: BoxDecoration(color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent, border: Border.all(color: isSelected ? color : Colors.transparent, width: 1.5)),
           child: Column(children: [Icon(icon, color: color, size: 24), const SizedBox(height: 4), Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 8, color: color))]),
        ),
     );
  }
}
