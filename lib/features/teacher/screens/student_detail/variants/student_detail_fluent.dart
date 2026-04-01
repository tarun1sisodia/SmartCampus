import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/student_detail_controller.dart';
import '../../../../models/student_model.dart';
import '../../../../../common/utils/constants/api_constants.dart';

class StudentDetailFluent extends StatelessWidget {
  final StudentDetailController controller;
  final StudentModel student;

  const StudentDetailFluent({super.key, required this.controller, required this.student});

  @override
  Widget build(BuildContext context) {
    const fluentBg = Color(0xFFF3F3F3);

    return Container(
      color: fluentBg,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF0078D4)));
        }

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildFluentHeader(context),
            const SizedBox(height: 32),
            _buildFluentStatsHUD(),
            const SizedBox(height: 48),
            const Text('Attendance History Log', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF201F1E))),
            const SizedBox(height: 16),
            _buildFluentLogStream(context),
            const SizedBox(height: 64),
          ],
        );
      }),
    );
  }

  Widget _buildFluentHeader(BuildContext context) {
    final cur = controller.student.value;
    final hasImg = cur?.imageUrl != null && cur!.imageUrl!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          GestureDetector(
             onTap: () => _updatePhoto(context),
             child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(40), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
                child: Stack(
                   children: [
                      Positioned.fill(child: ClipOval(child: hasImg ? CachedNetworkImage(imageUrl: ApiConstants.optimizeImageUrl(cur!.imageUrl!, width: 160, height: 160), fit: BoxFit.cover) : Icon(Iconsax.user, color: Colors.black.withValues(alpha: 0.2), size: 32))),
                      Positioned(right: 0, bottom: 0, child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Color(0xFF0078D4), shape: BoxShape.circle), child: const Icon(Iconsax.camera, color: Colors.white, size: 12))),
                      if (controller.isImageUploading.value) Positioned.fill(child: Container(decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle), child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))),
                   ],
                ),
             ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cur?.name ?? student.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF201F1E))),
                Text('Scholar ID: ${cur?.rollNumber ?? student.rollNumber}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.black.withValues(alpha: 0.4))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFluentStatsHUD() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
      child: Column(
        children: [
           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Metrics Visibility', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF201F1E))), Text('Synced with global cloud', style: TextStyle(fontSize: 10, color: Color(0xFFA19F9D)))]),
              CircularPercentIndicator(
                 radius: 32, lineWidth: 4,
                 percent: controller.attendancePercentage.value / 100,
                 center: Text('${controller.attendancePercentage.value.toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF0078D4))),
                 progressColor: const Color(0xFF0078D4), backgroundColor: const Color(0xFFF3F3F3), circularStrokeCap: CircularStrokeCap.round,
              ),
           ]),
           const SizedBox(height: 24),
           Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _stNode('Sessions', '${controller.totalSessions}', const Color(0xFF201F1E)),
              _stNode('Present', '${controller.presentCount}', Colors.green),
              _stNode('Absent', '${controller.absentCount}', Colors.red),
           ]),
        ],
      ),
    );
  }

  Widget _stNode(String l, String v, Color c) {
    return Column(children: [Text(v, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: c)), Text(l, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9, color: Colors.black.withValues(alpha: 0.3)))]);
  }

  Widget _buildFluentLogStream(BuildContext context) {
    if (controller.attendanceHistory.isEmpty) return const Center(child: Text('History stream clear', style: TextStyle(color: Color(0xFFA19F9D), fontSize: 13)));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.attendanceHistory.length,
      itemBuilder: (context, index) {
        final rec = controller.attendanceHistory[index];
        final session = rec['session'];
        final status = rec['status'] as String;
        final col = _getColor(status);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black.withValues(alpha: 0.01))),
          child: ListTile(
             onTap: () => _updateEntry(context, session.id, status, rec['remarks']),
             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: col.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20)), child: Center(child: Icon(_getIcon(status), color: col, size: 18))),
             title: Text(DateFormat('EEEE, MMM d').format(session.date), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF201F1E))),
             subtitle: Text('${session.startTime} - ${session.endTime}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.black.withValues(alpha: 0.3))),
             trailing: Text(status.toUpperCase(), style: TextStyle(color: col, fontWeight: FontWeight.w800, fontSize: 9)),
          ),
        );
      },
    );
  }

  void _updateEntry(BuildContext context, String sid, String current, String? rem) {
     final sc = current.obs;
     final t = TextEditingController(text: rem);
     Get.bottomSheet(Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
           const Text('Update Node Entry', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
           const SizedBox(height: 24),
           Obx(() => Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _btn('P', Colors.green, sc.value == 'present', () => sc.value = 'present'),
              _btn('A', Colors.red, sc.value == 'absent', () => sc.value = 'absent'),
              _btn('L', Colors.orange, sc.value == 'late', () => sc.value = 'late'),
           ])),
           const SizedBox(height: 24),
           TextField(controller: t, style: const TextStyle(fontSize: 13), decoration: InputDecoration(hintText: 'Notes...', filled: true, fillColor: const Color(0xFFF3F3F3), border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none))),
           const SizedBox(height: 32),
           SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { controller.updateAttendanceRecord(sessionId: sid, status: sc.value, remarks: t.text.isEmpty?null:t.text); Get.back(); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0078D4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), padding: const EdgeInsets.all(16)), child: const Text('Confirm Change', style: TextStyle(fontWeight: FontWeight.w800)))),
        ]),
     ));
  }

  Widget _btn(String l, Color c, bool s, VoidCallback t) {
     return InkWell(onTap: t, child: Container(width: 44, height: 44, decoration: BoxDecoration(color: s ? c : Colors.transparent, borderRadius: BorderRadius.circular(4), border: Border.all(color: s ? c : Colors.black.withValues(alpha: 0.1))), child: Center(child: Text(l, style: TextStyle(color: s ? Colors.white : Colors.black.withValues(alpha: 0.2), fontWeight: FontWeight.w800)))));
  }

  Color _getColor(String s) {
    if (s == 'present') return Colors.green;
    if (s == 'absent') return Colors.red;
    return Colors.orange;
  }

  IconData _getIcon(String s) {
    if (s == 'present') return Iconsax.verify;
    if (s == 'absent') return Iconsax.close_circle;
    return Iconsax.clock;
  }

  void _updatePhoto(BuildContext context) {
    Get.bottomSheet(Container(
       padding: const EdgeInsets.all(32),
       decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
       child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Update Profile Source', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 24),
          _pTile('Optical Camera', Iconsax.camera, () { Get.back(); controller.pickImage(ImageSource.camera).then((_) { if(controller.selectedImage.value != null) controller.updateStudentImage(); }); }),
          _pTile('Explorer Storage', Iconsax.gallery, () { Get.back(); controller.pickImage(ImageSource.gallery).then((_) { if(controller.selectedImage.value != null) controller.updateStudentImage(); }); }),
       ]),
    ));
  }

  Widget _pTile(String l, IconData i, VoidCallback t) {
     return InkWell(onTap: t, child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(4)), child: Row(children: [Icon(i, color: const Color(0xFF0078D4), size: 20), const SizedBox(width: 16), Text(l, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))])));
  }
}
