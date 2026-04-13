import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../controllers/student_detail_controller.dart';
import '../../../../../models/student_model.dart';
import '../../../../../common/utils/constants/api_constants.dart';

class StudentDetailNeumorphism extends StatelessWidget {
  final StudentDetailController controller;
  final StudentModel student;

  const StudentDetailNeumorphism({super.key, required this.controller, required this.student});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFE0E5EC);
    
    return Container(
      color: bgColor,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFA3B1C6)));
        }

        return ListView(
          padding: const EdgeInsets.all(28),
          children: [
            _buildNeuHeader(context, bgColor),
            const SizedBox(height: 48),
            _buildNeuPerformanceHUD(bgColor),
            const SizedBox(height: 48),
            _buildNeuHistorySection(context, bgColor),
            const SizedBox(height: 64),
          ],
        );
      }),
    );
  }

  Widget _buildNeuHeader(BuildContext context, Color bg) {
    final cur = controller.student.value;
    final hasImage = cur?.imageUrl != null && cur!.imageUrl!.isNotEmpty;

    return Column(
      children: [
        GestureDetector(
          onTap: () => _updatePhoto(context, bg),
          child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.white, offset: const Offset(-8, -8), blurRadius: 16), BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(8, 8), blurRadius: 16)]),
            child: Padding(
               padding: const EdgeInsets.all(4),
               child: ClipOval(
                  child: hasImage 
                     ? CachedNetworkImage(imageUrl: ApiConstants.optimizeImageUrl(cur!.imageUrl!, width: 200, height: 200), fit: BoxFit.cover)
                     : const Icon(Iconsax.user, color: Color(0xFFA3B1C6), size: 40),
               ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(cur?.name ?? student.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF4D565F))),
        Text('NODE_ID: ${cur?.rollNumber ?? student.rollNumber}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFFA3B1C6))),
      ],
    );
  }

  Widget _buildNeuPerformanceHUD(Color bg) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.white, offset: const Offset(-8, -8), blurRadius: 16), BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(8, 8), blurRadius: 16)]),
      child: Column(
        children: [
           Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Metrics Overview', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF4D565F))), Text('Real-time synchronization', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: Color(0xFFA3B1C6)))]),
                 CircularPercentIndicator(
                   radius: 36, lineWidth: 6,
                   percent: controller.attendancePercentage.value / 100,
                   center: Text('${controller.attendancePercentage.value.toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF4D565F))),
                   progressColor: const Color(0xFF6D5DFC), backgroundColor: Colors.white.withValues(alpha: 0.5), circularStrokeCap: CircularStrokeCap.round,
                 ),
              ],
           ),
           const SizedBox(height: 32),
           Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                 _neuStatNode('Valid', '${controller.presentCount}', Colors.green),
                 _neuStatNode('Void', '${controller.absentCount}', Colors.red),
                 _neuStatNode('Delay', '${controller.lateCount}', Colors.orange),
              ],
           ),
        ],
      ),
    );
  }

  Widget _neuStatNode(String l, String v, Color c) {
    return Column(children: [Text(v, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: c)), Text(l, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 9, color: Color(0xFFA3B1C6)))]);
  }

  Widget _buildNeuHistorySection(BuildContext context, Color bg) {
    if (controller.attendanceHistory.isEmpty) return const Center(child: Text('Empty stream logs', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFA3B1C6))));

    return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
          const Padding(padding: EdgeInsets.only(left: 8), child: Text('Attendance Records', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF4D565F)))),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.attendanceHistory.length,
            itemBuilder: (context, index) {
              final record = controller.attendanceHistory[index];
              final status = record['status'] as String;
              final session = record['session'];
              final color = _getStatusColor(status);

              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.white, offset: const Offset(-5, -5), blurRadius: 10), BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(5, 5), blurRadius: 10)]),
                child: ListTile(
                   onTap: () => _modReg(context, session.id, status, record['remarks'], bg),
                   contentPadding: const EdgeInsets.all(16),
                   leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: bg, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 4), BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(2, 2), blurRadius: 4)]), child: Center(child: Icon(_getIcon(status), color: color, size: 18))),
                   title: Text(DateFormat('MMM d, yyyy').format(session.date), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF4D565F))),
                   subtitle: Text('${session.startTime} > ${session.endTime}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: Color(0xFFA3B1C6))),
                   trailing: Text(status.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 8)),
                ),
              );
            },
          ),
       ],
    );
  }

  void _modReg(BuildContext context, String sid, String cur, String? rem, Color bg) {
     final sc = cur.obs;
     final t = TextEditingController(text: rem);
     Get.bottomSheet(Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
           const Text('Modify Node Status', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
           const SizedBox(height: 32),
           Obx(() => Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _btn('P', Colors.green, sc.value == 'present', () => sc.value = 'present', bg),
              _btn('A', Colors.red, sc.value == 'absent', () => sc.value = 'absent', bg),
              _btn('L', Colors.orange, sc.value == 'late', () => sc.value = 'late', bg),
           ])),
           const SizedBox(height: 32),
           Container(padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 4, inset: true), BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(2, 2), blurRadius: 4, inset: true)]), child: TextField(controller: t, decoration: const InputDecoration(hintText: 'Notes...', border: InputBorder.none))),
           const SizedBox(height: 32),
           SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { controller.updateAttendanceRecord(sessionId: sid, status: sc.value, remarks: t.text.isEmpty?null:t.text); Get.back(); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6D5DFC), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.all(16)), child: const Text('Update Record'))),
        ]),
     ));
  }

  Widget _btn(String l, Color c, bool s, VoidCallback t, Color bg) {
     return InkWell(onTap: t, child: Container(width: 50, height: 50, decoration: BoxDecoration(color: bg, shape: BoxShape.circle, boxShadow: s ? [BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 4, inset: true), BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(2, 2), blurRadius: 4, inset: true)] : [BoxShadow(color: Colors.white, offset: const Offset(-4, -4), blurRadius: 8), BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(4, 4), blurRadius: 8)]), child: Center(child: Text(l, style: TextStyle(color: s ? c : const Color(0xFFA3B1C6), fontWeight: FontWeight.w900)))));
  }

  Color _getStatusColor(String s) {
    if (s == 'present') return Colors.green;
    if (s == 'absent') return Colors.red;
    return Colors.orange;
  }

  IconData _getIcon(String s) {
    if (s == 'present') return Iconsax.verify;
    if (s == 'absent') return Iconsax.close_circle;
    return Iconsax.clock;
  }

  void _updatePhoto(BuildContext context, Color bg) {
     Get.bottomSheet(Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
           const Text('Identifier Asset Management', style: TextStyle(fontWeight: FontWeight.w900)),
           const SizedBox(height: 24),
           ListTile(leading: const Icon(Iconsax.camera), title: const Text('Capture Point', style: TextStyle(fontWeight: FontWeight.w800)), onTap: () { Get.back(); controller.pickImage(ImageSource.camera).then((_) { if(controller.selectedImage.value != null) controller.updateStudentImage(); }); }),
           ListTile(leading: const Icon(Iconsax.gallery), title: const Text('Import Stream', style: TextStyle(fontWeight: FontWeight.w800)), onTap: () { Get.back(); controller.pickImage(ImageSource.gallery).then((_) { if(controller.selectedImage.value != null) controller.updateStudentImage(); }); }),
        ]),
     ));
  }
}
