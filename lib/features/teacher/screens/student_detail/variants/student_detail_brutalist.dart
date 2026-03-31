import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/student_detail_controller.dart';
import '../../../../models/student_model.dart';
import '../../../../common/utils/constants/api_constants.dart';

class StudentDetailBrutalist extends StatelessWidget {
  final StudentDetailController controller;
  final StudentModel student;

  const StudentDetailBrutalist({super.key, required this.controller, required this.student});

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFE14D);
    const orange = Color(0xFFFF8C42);
    const blue = Color(0xFF4D91FF);

    return Container(
      color: Colors.white,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildBrutalProfile(context, yellow),
            const SizedBox(height: 32),
            _buildBrutalStatsHUD(blue, orange),
            const SizedBox(height: 48),
            const Text('ACTIVITY_HISTORY_01', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.black, letterSpacing: 1)),
            const SizedBox(height: 16),
            _buildBrutalLogStream(context, orange, blue),
            const SizedBox(height: 64),
          ],
        );
      }),
    );
  }

  Widget _buildBrutalProfile(BuildContext context, Color yellow) {
    final cur = controller.student.value;
    final hasImg = cur?.imageUrl != null && cur!.imageUrl!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: yellow, border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(8, 8))]),
      child: Row(
        children: [
          GestureDetector(
             onTap: () => _updatePhoto(context, yellow),
             child: Container(
                width: 90, height: 90,
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 2.5), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))]),
                child: Stack(
                   children: [
                      Positioned.fill(child: hasImg ? CachedNetworkImage(imageUrl: ApiConstants.optimizeImageUrl(cur!.imageUrl!, width: 180, height: 180), fit: BoxFit.cover) : const Icon(Iconsax.user, color: Colors.black, size: 40)),
                      Positioned(right: 0, bottom: 0, child: Container(padding: const EdgeInsets.all(4), color: Colors.black, child: const Icon(Iconsax.camera, color: Colors.white, size: 14))),
                      if (controller.isImageUploading.value) Positioned.fill(child: Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator(color: Colors.white)))),
                   ],
                ),
             ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cur?.name.toUpperCase() ?? student.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black, letterSpacing: 0.5)),
                Text('NODE_ID: ${cur?.rollNumber ?? student.rollNumber}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrutalStatsHUD(Color blue, Color orange) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 3), boxShadow: [BoxShadow(color: blue, offset: const Offset(6, 6))]),
      child: Column(
        children: [
           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('PERFORMANCE_DATA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              Text('${controller.attendancePercentage.value.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
           ]),
           const SizedBox(height: 24),
           Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _stNode('SESS', '${controller.totalSessions}', Colors.black),
              _stNode('PRES', '${controller.presentCount}', Colors.green),
              _stNode('ABSN', '${controller.absentCount}', orange),
              _stNode('LATE', '${controller.lateCount}', blue),
           ]),
        ],
      ),
    );
  }

  Widget _stNode(String l, String v, Color c) {
    return Column(children: [Text(v, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: c)), Text(l, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Colors.black38))]);
  }

  Widget _buildBrutalLogStream(BuildContext context, Color orange, Color blue) {
    if (controller.attendanceHistory.isEmpty) return const Center(child: Text('LOG_VOID_01', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black26)));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.attendanceHistory.length,
      itemBuilder: (context, index) {
        final rec = controller.attendanceHistory[index];
        final status = rec['status'] as String;
        final col = _getColor(status, orange, blue);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 3), boxShadow: [BoxShadow(color: col.withOpacity(0.5), offset: const Offset(4, 4))]),
          child: ListTile(
             onTap: () => _updateRec(context, rec['session'].id, status, rec['remarks'], orange, blue),
             contentPadding: const EdgeInsets.all(16),
             leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: col.withOpacity(0.1), border: Border.all(color: Colors.black, width: 2)), child: Icon(_getIcon(status), color: Colors.black, size: 20)),
             title: Text(DateFormat('yyyy_MM_dd').format(rec['session'].date).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
             subtitle: Text('${rec['session'].startTime} > ${rec['session'].endTime}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Colors.black45)),
             trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: col, border: Border.all(color: Colors.black, width: 2)), child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8))),
          ),
        );
      },
    );
  }

  void _updateRec(BuildContext context, String sid, String current, String? rem, Color orange, Color blue) {
    final sel = current.obs;
    final rtc = TextEditingController(text: rem);

    Get.dialog(AlertDialog(
       backgroundColor: Colors.white,
       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero, border: Border.all(color: Colors.black, width: 3)),
       title: const Text('MODIFY_RECORD_01', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
       content: Column(mainAxisSize: MainAxisSize.min, children: [
          Obx(() => Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
             _stBtn('PA', Colors.green, sel.value == 'present', () => sel.value = 'present'),
             _stBtn('AB', orange, sel.value == 'absent', () => sel.value = 'absent'),
             _stBtn('LT', blue, sel.value == 'late', () => sel.value = 'late'),
          ])),
          const SizedBox(height: 24),
          Container(decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black, width: 2.5))), child: TextField(controller: rtc, decoration: const InputDecoration(hintText: 'DATA_NODE_REMARKS', border: InputBorder.none, hintStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.black12)))),
       ]),
       actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('DISCARD_S01', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black54))),
          ElevatedButton(onPressed: () { controller.updateAttendanceRecord(sessionId: sid, status: sel.value, remarks: rtc.text.isEmpty?null:rtc.text); Get.back(); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)), child: const Text('COMMIT_01')),
       ],
    ));
  }

  Widget _stBtn(String l, Color c, bool s, VoidCallback t) {
     return InkWell(onTap: t, child: Container(width: 44, height: 44, decoration: BoxDecoration(color: s ? c : Colors.white, border: Border.all(color: Colors.black, width: 2.5), boxShadow: s ? null : const [BoxShadow(color: Colors.black, offset: Offset(2, 2))]), child: Center(child: Text(l, style: TextStyle(color: s ? Colors.white : Colors.black, fontWeight: FontWeight.w900)))));
  }

  Color _getColor(String s, Color orange, Color blue) {
    if (s == 'present') return Colors.green;
    if (s == 'absent') return orange;
    return blue;
  }

  IconData _getIcon(String s) {
    if (s == 'present') return Iconsax.verify;
    if (s == 'absent') return Iconsax.close_circle;
    return Iconsax.clock;
  }

  void _updatePhoto(BuildContext context, Color yellow) {
    Get.bottomSheet(Container(
       padding: const EdgeInsets.all(32),
       decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black, width: 4))),
       child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('ASSET_MOD_STREAM', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          _pTile('CAMERA_UNIT_SOURCE', Iconsax.camera, () { Get.back(); controller.pickImage(ImageSource.camera).then((_) { if(controller.selectedImage.value != null) controller.updateStudentImage(); }); }),
          const SizedBox(height: 12),
          _pTile('STORAGE_IMPORT_01', Iconsax.gallery, () { Get.back(); controller.pickImage(ImageSource.gallery).then((_) { if(controller.selectedImage.value != null) controller.updateStudentImage(); }); }),
       ]),
    ));
  }

  Widget _pTile(String l, IconData i, VoidCallback t) {
     return InkWell(onTap: t, child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2.5), color: Colors.white, boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))]), child: Row(children: [Icon(i, color: Colors.black, size: 20), const SizedBox(width: 16), Text(l, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12))])));
  }
}
