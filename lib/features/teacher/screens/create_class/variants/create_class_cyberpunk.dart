import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/class_controller.dart';

class CreateClassCyberpunk extends StatelessWidget {
  final ClassController controller;

  const CreateClassCyberpunk({super.key, required this.controller});

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
          Obx(() => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator(color: cyan))
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                children: [
                  _buildCyberHeader(cyan, magenta),
                  const SizedBox(height: 48),
                  _buildCyberSection('CORE_PROTOCOL_INIT', [
                    _buildCyberDropdown<dynamic>(
                      label: 'subject_uplink',
                      icon: Iconsax.book_1,
                      value: controller.selectedSubject.value,
                      items: controller.subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toString().toUpperCase(), style: const TextStyle(color: cyan, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Courier')))).toList(),
                      onChanged: (v) => controller.selectedSubject.value = v,
                      cyan: cyan,
                    ),
                    const SizedBox(height: 24),
                    _buildCyberDropdown<dynamic>(
                      label: 'course_registry',
                      icon: Iconsax.teacher,
                      value: controller.selectedCourse.value,
                      items: controller.courses.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toString().toUpperCase(), style: const TextStyle(color: cyan, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Courier')))).toList(),
                      onChanged: (v) => controller.selectedCourse.value = v,
                      cyan: cyan,
                    ),
                  ], cyan),
                  const SizedBox(height: 32),
                  _buildCyberSection('METRICS_DEFINITION', [
                    Row(
                      children: [
                        Expanded(
                          child: _buildCyberField(
                            controller: controller.semesterController,
                            label: 'SEM_NODE',
                            hint: '1-8',
                            icon: Iconsax.calendar_tick,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly, FilteringTextInputFormatter.allow(RegExp(r'^[1-8]$'))],
                            cyan: cyan,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildCyberField(
                            controller: controller.sectionController,
                            label: 'SEC_PORT',
                            hint: 'A-Z',
                            icon: Iconsax.grid_5,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[A-Z]$'))],
                            cyan: cyan,
                          ),
                        ),
                      ],
                    ),
                  ], magenta),
                  const SizedBox(height: 64),
                  _buildCyberButton(cyan, magenta),
                  const SizedBox(height: 32),
                  Center(child: Text('UPLINK_STATUS: SECURE_STABLE', style: TextStyle(color: cyan.withOpacity(0.3), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2, fontFamily: 'Courier'))),
                  const SizedBox(height: 100),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildGridOverlay(Color cyan) {
    return Positioned.fill(child: CustomPaint(painter: _GridPainter(color: cyan.withOpacity(0.03))));
  }

  Widget _buildCyberHeader(Color cyan, Color magenta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('INITIATE', style: TextStyle(color: magenta, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: 2, fontFamily: 'Courier')),
        Text('NEW_CLASS_STREAM_NODE', style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1, fontFamily: 'Courier')),
        const SizedBox(height: 8),
        Container(width: 40, height: 4, color: cyan),
      ],
    );
  }

  Widget _buildCyberSection(String title, List<Widget> items, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(title, style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, fontFamily: 'Courier')),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.black, border: Border.all(color: accent.withOpacity(0.3), width: 1.5)),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildCyberDropdown<T>({required String label, required IconData icon, required T? value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged, required Color cyan}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: cyan.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'Courier')),
        const SizedBox(height: 12),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          dropdownColor: Colors.black,
          icon: Icon(Iconsax.arrow_down_1, color: cyan, size: 18),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: cyan, size: 20),
            filled: true, fillColor: Colors.black,
            border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: cyan.withOpacity(0.3))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: cyan.withOpacity(0.3))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: cyan, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildCyberField({required TextEditingController controller, required String label, required String hint, required IconData icon, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters, required Color cyan}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: cyan.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'Courier')),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: TextStyle(color: cyan, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Courier'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: cyan.withOpacity(0.2), fontSize: 14, fontFamily: 'Courier'),
            prefixIcon: Icon(icon, color: cyan, size: 20),
            filled: true, fillColor: Colors.black,
            border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: cyan.withOpacity(0.3))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: cyan.withOpacity(0.3))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: cyan, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildCyberButton(Color cyan, Color magenta) {
    return GestureDetector(
      onTap: () => controller.createClass(),
      child: Container(
        height: 64,
        decoration: BoxDecoration(color: magenta.withOpacity(0.1), border: Border.all(color: magenta, width: 2), boxShadow: [BoxShadow(color: magenta.withOpacity(0.2), blurRadius: 10)]),
        child: Center(
          child: Text('INITIALIZE_UPLINK_STREAM_X01', style: TextStyle(color: magenta, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2, fontFamily: 'Courier')),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..strokeWidth = 1.0;
    const double step = 30.0;
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
