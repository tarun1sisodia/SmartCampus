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

class StudentDetailAcademic extends StatelessWidget {
  final StudentDetailController controller;
  final StudentModel student;

  const StudentDetailAcademic({super.key, required this.controller, required this.student});

  @override
  Widget build(BuildContext context) {
    const paperColor = Color(0xFFFAF7F0);
    const inkColor = Color(0xFF2D2E32);
    const accentColor = Color(0xFF8B4513); // Saddle Brown

    return Container(
      color: paperColor,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: accentColor));
        }

        return ListView(
          padding: const EdgeInsets.all(28),
          children: [
            _buildScholarProfile(context, accentColor, inkColor),
            const SizedBox(height: 48),
            _buildScholarPerformance(accentColor, inkColor),
            const SizedBox(height: 48),
            _buildScholarHistory(context, accentColor, inkColor),
            const SizedBox(height: 64),
          ],
        );
      }),
    );
  }

  Widget _buildScholarProfile(BuildContext context, Color accent, Color ink) {
    final cur = controller.student.value;
    final hasImg = cur?.imageUrl != null && cur!.imageUrl!.isNotEmpty;

    return Column(
      children: [
        GestureDetector(
          onTap: () => _updatePhoto(context, accent, ink),
          child: Container(
             width: 100, height: 100,
             decoration: BoxDecoration(color: Colors.white, border: Border.all(color: accent.withValues(alpha: 0.3))),
             child: Padding(
                padding: const EdgeInsets.all(4),
                child: hasImg 
                   ? CachedNetworkImage(imageUrl: ApiConstants.optimizeImageUrl(cur!.imageUrl!, width: 200, height: 200), fit: BoxFit.cover)
                   : Icon(Iconsax.user, color: accent.withValues(alpha: 0.3), size: 40),
             ),
          ),
        ),
        const SizedBox(height: 24),
        Text(cur?.name ?? student.name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: ink, fontFamily: 'Serif')),
        Text('Roll Number: ${cur?.rollNumber ?? student.rollNumber}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: ink.withValues(alpha: 0.5), fontFamily: 'Serif')),
      ],
    );
  }

  Widget _buildScholarPerformance(Color accent, Color ink) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: accent.withValues(alpha: 0.1))),
      child: Column(
        children: [
           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Academic Attendance', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: ink, fontFamily: 'Serif')),
              CircularPercentIndicator(
                 radius: 36, lineWidth: 5,
                 percent: controller.attendancePercentage.value / 100,
                 center: Text('${controller.attendancePercentage.value.toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: ink, fontFamily: 'Serif')),
                 progressColor: accent, backgroundColor: const Color(0xFFFAF7F0), circularStrokeCap: CircularStrokeCap.round,
              ),
           ]),
           const SizedBox(height: 32),
           Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _stNode('Sessions', '${controller.totalSessions}', ink),
              _stNode('Present', '${controller.presentCount}', Colors.green),
              _stNode('Absent', '${controller.absentCount}', Colors.red),
           ]),
        ],
      ),
    );
  }

  Widget _stNode(String l, String v, Color ink) {
    return Column(children: [Text(v, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: ink, fontFamily: 'Serif')), Text(l, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: ink.withValues(alpha: 0.4), fontFamily: 'Serif'))]);
  }

  Widget _buildScholarHistory(BuildContext context, Color accent, Color ink) {
    if (controller.attendanceHistory.isEmpty) return const Center(child: Text('Registry Log Empty', style: TextStyle(fontFamily: 'Serif')));

    return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
          Text('Enrollment History'.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5, color: accent.withValues(alpha: 0.4), fontFamily: 'Serif')),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.attendanceHistory.length,
            itemBuilder: (context, index) {
              final rec = controller.attendanceHistory[index];
              final status = rec['status'] as String;
              final col = _getColor(status);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: accent.withValues(alpha: 0.05))),
                child: ListTile(
                   onTap: () => _updateRec(context, rec['session'].id, status, rec['remarks'], accent, ink),
                   contentPadding: const EdgeInsets.all(16),
                   leading: Icon(_getIcon(status), color: col, size: 20),
                   title: Text(DateFormat('EEEE, MMMM d, yyyy').format(rec['session'].date), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: ink, fontFamily: 'Serif')),
                   subtitle: Text('${rec['session'].startTime} - ${rec['session'].endTime}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: ink.withValues(alpha: 0.4), fontFamily: 'Serif')),
                   trailing: Text(status.toUpperCase(), style: TextStyle(color: col, fontWeight: FontWeight.w800, fontSize: 9, fontFamily: 'Serif')),
                ),
              );
            },
          ),
       ],
    );
  }

  void _updateRec(BuildContext context, String sid, String cur, String? rem, Color accent, Color ink) {
     final sc = cur.obs;
     final t = TextEditingController(text: rem);
     Get.dialog(AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, border: Border.all(color: accent, width: 2)),
        title: Text('Amend Enrollment Receipt', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: ink, fontFamily: 'Serif')),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
           Obx(() => Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _btn('P', Colors.green, sc.value == 'present', () => sc.value = 'present', accent),
              _btn('A', Colors.red, sc.value == 'absent', () => sc.value = 'absent', accent),
              _btn('L', Colors.orange, sc.value == 'late', () => sc.value = 'late', accent),
           ])),
           const SizedBox(height: 24),
           TextField(controller: t, style: TextStyle(fontFamily: 'Serif', fontSize: 13), decoration: InputDecoration(labelText: 'Observation Remarks', labelStyle: TextStyle(fontSize: 10, fontFamily: 'Serif'), border: UnderlineInputBorder(borderSide: BorderSide(color: accent.withValues(alpha: 0.2))))),
        ]),
        actions: [
           TextButton(onPressed: () => Get.back(), child: const Text('Discard', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black45, fontFamily: 'Serif'))),
           ElevatedButton(onPressed: () { controller.updateAttendanceRecord(sessionId: sid, status: sc.value, remarks: t.text.isEmpty?null:t.text); Get.back(); }, style: ElevatedButton.styleFrom(backgroundColor: ink, foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)), child: const Text('Confirm', style: TextStyle(fontFamily: 'Serif'))),
        ],
     ));
  }

  Widget _btn(String l, Color c, bool s, VoidCallback t, Color accent) {
     return InkWell(onTap: t, child: Container(width: 44, height: 44, decoration: BoxDecoration(color: s ? accent.withValues(alpha: 0.1) : Colors.transparent, border: Border.all(color: s ? accent : Colors.black12)), child: Center(child: Text(l, style: TextStyle(color: s ? accent : Colors.black26, fontWeight: FontWeight.w900)))));
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

  void _updatePhoto(BuildContext context, Color accent, Color ink) {
    Get.bottomSheet(Container(
       padding: const EdgeInsets.all(32),
       decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFF8B4513), width: 3))),
       child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Enrollment Asset Records', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, fontFamily: 'Serif')),
          const SizedBox(height: 24),
          _pTile('Optical Image Source', Iconsax.camera, accent, () { Get.back(); controller.pickImage(ImageSource.camera).then((_) { if(controller.selectedImage.value != null) controller.updateStudentImage(); }); }),
          _pTile('Academic Archive', Iconsax.gallery, accent, () { Get.back(); controller.pickImage(ImageSource.gallery).then((_) { if(controller.selectedImage.value != null) controller.updateStudentImage(); }); }),
       ]),
    ));
  }

  Widget _pTile(String l, IconData i, Color c, VoidCallback t) {
     return InkWell(onTap: t, child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border.all(color: c.withValues(alpha: 0.1)), color: const Color(0xFFFAF7F0)), child: Row(children: [Icon(i, color: c, size: 20), const SizedBox(width: 16), Text(l, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, fontFamily: 'Serif'))])));
  }
}
