import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../controllers/student_detail_controller.dart';
import '../../../../../models/student_model.dart';
import '../../../../../common/utils/constants/api_constants.dart';

class StudentDetailCyberpunk extends StatelessWidget {
  final StudentDetailController controller;
  final StudentModel student;

  const StudentDetailCyberpunk({super.key, required this.controller, required this.student});

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF000814);
    const cyan = Color(0xFF00F5FF);
    const magenta = Color(0xFFFF00CC);

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          _buildGridOverlay(cyan),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: cyan));
            }

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildCyberProfile(context, cyan, magenta),
                const SizedBox(height: 32),
                _buildCyberHUD(cyan, magenta),
                const SizedBox(height: 48),
                _buildCyberLogStream(context, cyan, magenta),
                const SizedBox(height: 64),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGridOverlay(Color cyan) {
    return Positioned.fill(child: CustomPaint(painter: _GridPainter(color: cyan.withValues(alpha: 0.04))));
  }

  Widget _buildCyberProfile(BuildContext context, Color cyan, Color magenta) {
    final cur = controller.student.value;
    final hasImg = cur?.imageUrl != null && cur!.imageUrl!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.black, border: Border.all(color: cyan.withValues(alpha: 0.3)), boxShadow: [BoxShadow(color: cyan.withValues(alpha: 0.1), blurRadius: 10)]),
      child: Column(
        children: [
          GestureDetector(
             onTap: () => _updatePhoto(context, cyan, magenta),
             child: Container(
                width: 90, height: 90,
                decoration: BoxDecoration(color: Colors.black, border: Border.all(color: cyan, width: 2)),
                child: Stack(
                   children: [
                      Positioned.fill(child: hasImg ? CachedNetworkImage(imageUrl: ApiConstants.optimizeImageUrl(cur!.imageUrl!, width: 180, height: 180), fit: BoxFit.cover) : Icon(Iconsax.user, color: cyan, size: 32)),
                      Positioned(right: 0, bottom: 0, child: Container(padding: const EdgeInsets.all(4), color: cyan, child: const Icon(Iconsax.camera, color: Colors.black, size: 12))),
                      if (controller.isImageUploading.value) Positioned.fill(child: Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator(color: Colors.white)))),
                   ],
                ),
             ),
          ),
          const SizedBox(height: 24),
          Text(cur?.name.toUpperCase() ?? student.name.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: cyan, letterSpacing: 1, fontFamily: 'Courier')),
          Text('NODE_ID: ${cur?.rollNumber ?? student.rollNumber}'.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: cyan.withValues(alpha: 0.5), fontFamily: 'Courier')),
        ],
      ),
    );
  }

  Widget _buildCyberHUD(Color cyan, Color magenta) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.black, border: Border.all(color: magenta.withValues(alpha: 0.3))),
      child: Column(
        children: [
           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('PERFORMANCE_HUB_v1.0', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: magenta, letterSpacing: 1, fontFamily: 'Courier')),
              Text('${controller.attendancePercentage.value.toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: cyan, fontFamily: 'Courier')),
           ]),
           const SizedBox(height: 24),
           Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _stNode('SESSIONS', '${controller.totalSessions}', cyan),
              _stNode('PRESENT', '${controller.presentCount}', Colors.greenAccent),
              _stNode('ABSENT', '${controller.absentCount}', Colors.redAccent),
              _stNode('LATE', '${controller.lateCount}', Colors.orangeAccent),
           ]),
        ],
      ),
    );
  }

  Widget _stNode(String l, String v, Color c) {
    return Column(children: [Text(v, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: c, fontFamily: 'Courier')), Text(l, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 8, color: c.withValues(alpha: 0.5), fontFamily: 'Courier'))]);
  }

  Widget _buildCyberLogStream(BuildContext context, Color cyan, Color magenta) {
    if (controller.attendanceHistory.isEmpty) return const Center(child: Text('LOG_STREAM_VOID', style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900, fontFamily: 'Courier')));

    return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
          Text('UPLINK_ACTIVITY_LEDGER'.toUpperCase(), style: TextStyle(color: cyan.withValues(alpha: 0.3), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5, fontFamily: 'Courier')),
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
                decoration: BoxDecoration(color: Colors.black, border: Border.all(color: cyan.withValues(alpha: 0.1))),
                child: ListTile(
                   onTap: () => _updateEntry(context, rec['session'].id, status, rec['remarks'], cyan, magenta),
                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                   leading: Icon(_getIcon(status), color: col, size: 20),
                   title: Text(DateFormat('yyyy_MM_dd').format(rec['session'].date), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: cyan, fontFamily: 'Courier')),
                   subtitle: Text('${rec['session'].startTime} > ${rec['session'].endTime}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: cyan.withValues(alpha: 0.4), fontFamily: 'Courier')),
                   trailing: Text(status.toUpperCase(), style: TextStyle(color: col, fontWeight: FontWeight.w900, fontSize: 9, fontFamily: 'Courier')),
                ),
              );
            },
          ),
       ],
    );
  }

  void _updateEntry(BuildContext context, String sid, String current, String? rem, Color cyan, Color magenta) {
    final sel = current.obs;
    final tc = TextEditingController(text: rem);

    Get.dialog(AlertDialog(
       backgroundColor: Colors.black,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: cyan, width: 2)),
       title: Text('TERMINAL_ENTRY_MOD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: cyan, fontFamily: 'Courier')),
       content: Column(mainAxisSize: MainAxisSize.min, children: [
          Obx(() => Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
             _stBtn('P', Colors.greenAccent, sel.value == 'present', () => sel.value = 'present', cyan),
             _stBtn('A', Colors.redAccent, sel.value == 'absent', () => sel.value = 'absent', cyan),
             _stBtn('L', Colors.orangeAccent, sel.value == 'late', () => sel.value = 'late', cyan),
          ])),
          const SizedBox(height: 24),
          Container(decoration: BoxDecoration(border: Border.all(color: cyan.withValues(alpha: 0.2)), color: cyan.withValues(alpha: 0.02)), child: TextField(controller: tc, style: TextStyle(color: cyan, fontSize: 13, fontFamily: 'Courier'), decoration: InputDecoration(hintText: 'IDENTIFIER_REMARKS', hintStyle: TextStyle(color: cyan.withValues(alpha: 0.3), fontSize: 10), border: InputBorder.none, contentPadding: const EdgeInsets.all(12)))),
       ]),
       actions: [
          TextButton(onPressed: () => Get.back(), child: Text('TERMINATE', style: TextStyle(color: magenta, fontWeight: FontWeight.w900, fontSize: 10))),
          ElevatedButton(onPressed: () { controller.updateAttendanceRecord(sessionId: sid, status: sel.value, remarks: tc.text.isEmpty?null:tc.text); Get.back(); }, style: ElevatedButton.styleFrom(backgroundColor: cyan, foregroundColor: Colors.black, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)), child: const Text('COMMIT_CHANGE')),
       ],
    ));
  }

  Widget _stBtn(String l, Color c, bool s, VoidCallback t, Color cyan) {
     return InkWell(onTap: t, child: Container(width: 44, height: 44, decoration: BoxDecoration(color: s ? cyan : Colors.transparent, border: Border.all(color: cyan)), child: Center(child: Text(l, style: TextStyle(color: s ? Colors.black : cyan, fontWeight: FontWeight.w900)))));
  }

  Color _getColor(String s) {
    if (s == 'present') return Colors.greenAccent;
    if (s == 'absent') return Colors.redAccent;
    return Colors.orangeAccent;
  }

  IconData _getIcon(String s) {
    if (s == 'present') return Iconsax.verify;
    if (s == 'absent') return Iconsax.close_circle;
    return Iconsax.clock;
  }

  void _updatePhoto(BuildContext context, Color cyan, Color magenta) {
    Get.bottomSheet(Container(
       padding: const EdgeInsets.all(32),
       color: Colors.black,
       child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('ASSET_SOURCE_MGMT', style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontFamily: 'Courier')),
          const SizedBox(height: 24),
          _pTile('CAMERA_UNIT', Iconsax.camera, cyan, () { Get.back(); controller.pickImage(ImageSource.camera).then((_) { if(controller.selectedImage.value != null) controller.updateStudentImage(); }); }),
          _pTile('BUFFER_DRIVE', Iconsax.gallery, cyan, () { Get.back(); controller.pickImage(ImageSource.gallery).then((_) { if(controller.selectedImage.value != null) controller.updateStudentImage(); }); }),
       ]),
    ));
  }

  Widget _pTile(String l, IconData i, Color c, VoidCallback t) {
     return InkWell(onTap: t, child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border.all(color: c.withValues(alpha: 0.3)), color: c.withValues(alpha: 0.02)), child: Row(children: [Icon(i, color: c, size: 20), const SizedBox(width: 16), Text(l, style: TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: 12, fontFamily: 'Courier'))])));
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..strokeWidth = 1.0;
    const double step = 40.0;
    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), p);
    }
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), p);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
