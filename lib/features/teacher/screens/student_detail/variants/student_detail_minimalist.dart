import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/student_detail_controller.dart';
import '../../../../models/student_model.dart';
import '../../../../common/utils/constants/api_constants.dart';

class StudentDetailMinimalist extends StatelessWidget {
  final StudentDetailController controller;
  final StudentModel student;

  const StudentDetailMinimalist({super.key, required this.controller, required this.student});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.softMinimalist);
    const bgColor = Color(0xFFF8FAFC);

    return Container(
      color: bgColor,
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: tokens['primary']));
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            _buildMinimalistProfile(context, tokens),
            const SizedBox(height: 32),
            _buildMinimalistStatsCard(context, tokens),
            const SizedBox(height: 32),
            _buildMinimalistHistorySection(context, tokens),
            const SizedBox(height: 64),
          ],
        );
      }),
    );
  }

  Widget _buildMinimalistProfile(BuildContext context, Map<String, dynamic> tokens) {
    final currentStudent = controller.student.value;
    final hasImage = currentStudent?.imageUrl != null && currentStudent!.imageUrl!.isNotEmpty;

    return Column(
      children: [
        GestureDetector(
          onTap: () => _showImageOptions(context, tokens),
          child: Stack(
            children: [
               Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))]),
                  child: ClipOval(
                     child: hasImage 
                        ? CachedNetworkImage(imageUrl: ApiConstants.optimizeImageUrl(currentStudent!.imageUrl!, width: 200, height: 200), fit: BoxFit.cover)
                        : Icon(Iconsax.user, color: tokens['primary'], size: 40),
                  ),
               ),
               Positioned(right: 0, bottom: 0, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: tokens['primary'], shape: BoxShape.circle), child: const Icon(Iconsax.camera, color: Colors.white, size: 16))),
               if (controller.isImageUploading.value) Positioned.fill(child: Container(decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle), child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(currentStudent?.name ?? student.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Color(0xFF1E293B))),
        Text('Roll ID: ${currentStudent?.rollNumber ?? student.rollNumber}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildMinimalistStatsCard(BuildContext context, Map<String, dynamic> tokens) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 40, offset: const Offset(0, 20))]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     const Text('Overall Attendance', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B))),
                     Text('Last updated just now', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.black.withOpacity(0.4))),
                  ],
               ),
               CircularPercentIndicator(
                  radius: 36, lineWidth: 6,
                  percent: controller.attendancePercentage.value / 100,
                  center: Text('${controller.attendancePercentage.value.toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  progressColor: tokens['primary'], backgroundColor: const Color(0xFFF1F5F9), circularStrokeCap: CircularStrokeCap.round,
               ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMinStatItem('Present', '${controller.presentCount}', Colors.green),
              _buildMinStatItem('Absent', '${controller.absentCount}', Colors.red),
              _buildMinStatItem('Late', '${controller.lateCount}', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMinStatItem(String label, String val, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: color)),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildMinimalistHistorySection(BuildContext context, Map<String, dynamic> tokens) {
    if (controller.attendanceHistory.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(48), child: Column(children: [Icon(Iconsax.calendar_1, size: 48, color: const Color(0xFFE2E8F0)), const SizedBox(height: 16), const Text('No history found', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))])));
    }

    return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
          const Padding(padding: EdgeInsets.only(left: 8), child: Text('Session History', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1E293B)))),
          const SizedBox(height: 16),
          ListView.builder(
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
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))),
                child: ListTile(
                   onTap: () => _updateStatus(context, session.id, status, record['remarks'], tokens),
                   contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                   leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(_getStatusIcon(status), color: color, size: 18)),
                   title: Text(DateFormat('EEEE, MMM d').format(session.date), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1E293B))),
                   subtitle: Text('${session.startTime} - ${session.endTime}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF94A3B8))),
                   trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(10)), child: Text(status.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 9))),
                ),
              );
            },
          ),
       ],
    );
  }

  void _updateStatus(BuildContext context, String sessionId, String current, String? remarks, Map<String, dynamic> tokens) {
     final selected = current.obs;
     final rs = TextEditingController(text: remarks);
     Get.bottomSheet(Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
           const Text('Update Attendance', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
           const SizedBox(height: 24),
           Obx(() => Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _stNode('Present', Iconsax.verify, Colors.green, selected.value == 'present', () => selected.value = 'present'),
              _stNode('Absent', Iconsax.close_circle, Colors.red, selected.value == 'absent', () => selected.value = 'absent'),
              _stNode('Late', Iconsax.clock, Colors.orange, selected.value == 'late', () => selected.value = 'late'),
           ])),
           const SizedBox(height: 24),
           TextField(controller: rs, decoration: InputDecoration(hintText: 'Add remarks...', filled: true, fillColor: const Color(0xFFF1F5F9), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
           const SizedBox(height: 32),
           SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { controller.updateAttendanceRecord(sessionId: sessionId, status: selected.value, remarks: rs.text.isEmpty ? null : rs.text); Get.back(); }, style: ElevatedButton.styleFrom(backgroundColor: tokens['primary'], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.all(16)), child: const Text('Update Record'))),
        ]),
     ));
  }

  Widget _stNode(String l, IconData i, Color c, bool s, VoidCallback t) {
     return InkWell(onTap: t, child: Column(children: [Icon(i, color: s ? c : const Color(0xFFE2E8F0), size: 28), const SizedBox(height: 8), Text(l, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: s ? c : const Color(0xFF94A3B8)))]));
  }

  Color _getStatusColor(String s) {
    if (s == 'present') return Colors.green;
    if (s == 'absent') return Colors.red;
    if (s == 'late') return Colors.orange;
    return const Color(0xFF1E293B);
  }

  IconData _getStatusIcon(String s) {
    if (s == 'present') return Iconsax.verify;
    if (s == 'absent') return Iconsax.close_circle;
    return Iconsax.clock;
  }

  void _showImageOptions(BuildContext context, Map<String, dynamic> tokens) {
     Get.bottomSheet(Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
           const Text('Student Profile Picture', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
           const SizedBox(height: 24),
           ListTile(leading: const Icon(Iconsax.camera), title: const Text('Capture Photo', style: TextStyle(fontWeight: FontWeight.w700)), onTap: () { Get.back(); controller.pickImage(ImageSource.camera).then((_) { if(controller.selectedImage.value != null) controller.updateStudentImage(); }); }),
           ListTile(leading: const Icon(Iconsax.gallery), title: const Text('Pick from Gallery', style: TextStyle(fontWeight: FontWeight.w700)), onTap: () { Get.back(); controller.pickImage(ImageSource.gallery).then((_) { if(controller.selectedImage.value != null) controller.updateStudentImage(); }); }),
        ]),
     ));
  }
}
