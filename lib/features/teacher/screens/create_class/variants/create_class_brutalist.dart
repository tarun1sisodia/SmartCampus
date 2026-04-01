import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/class_controller.dart';

class CreateClassBrutalist extends StatelessWidget {
  final ClassController controller;

  const CreateClassBrutalist({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFE14D);
    const orange = Color(0xFFFF8C42);
    const blue = Color(0xFF4D91FF);

    return Container(
      color: Colors.white,
      child: Obx(() => controller.isLoading.value
        ? const Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 4))
        : ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildBrutalHeader(yellow),
              const SizedBox(height: 48),
              _buildBrutalSection('STRUCTURAL_01', [
                _buildBrutalDropdown<dynamic>(
                  label: 'SUBJECT_ID',
                  icon: Iconsax.book_1,
                  value: controller.selectedSubject.value,
                  items: controller.subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)))).toList(),
                  onChanged: (v) => controller.selectedSubject.value = v,
                ),
                const SizedBox(height: 24),
                _buildBrutalDropdown<dynamic>(
                  label: 'COURSE_ID',
                  icon: Iconsax.teacher,
                  value: controller.selectedCourse.value,
                  items: controller.courses.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)))).toList(),
                  onChanged: (v) => controller.selectedCourse.value = v,
                ),
              ], blue),
              const SizedBox(height: 32),
              _buildBrutalSection('METRICS_01', [
                Row(
                  children: [
                    Expanded(
                      child: _buildBrutalField(
                        controller: controller.semesterController,
                        label: 'SEM',
                        hint: '1-8',
                        icon: Iconsax.calendar_tick,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, FilteringTextInputFormatter.allow(RegExp(r'^[1-8]$'))],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildBrutalField(
                        controller: controller.sectionController,
                        label: 'SEC',
                        hint: 'A-Z',
                        icon: Iconsax.grid_5,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[A-Z]$'))],
                      ),
                    ),
                  ],
                ),
              ], orange),
              const SizedBox(height: 64),
              _buildBrutalButton(orange),
              const SizedBox(height: 32),
              const Center(child: Text('VERSION_1.2.4_BOLD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2))),
              const SizedBox(height: 100),
            ],
          )),
    );
  }

  Widget _buildBrutalHeader(Color yellow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.black,
          child: const Text('CREATE_CLASS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: 2)),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          color: yellow,
          child: const Text('INITIALIZE_SESSION_REGISTRY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
        ),
      ],
    );
  }

  Widget _buildBrutalSection(String title, List<Widget> items, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 3), boxShadow: [BoxShadow(color: accent, offset: const Offset(8, 8))]),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildBrutalDropdown<T>({required String label, required IconData icon, required T? value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          icon: const Icon(Iconsax.arrow_down_1, color: Colors.black, size: 20),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.black, size: 24),
            filled: true, fillColor: Colors.white,
            border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.black, width: 2.5)),
            enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.black, width: 2.5)),
            focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.black, width: 4)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildBrutalField({required TextEditingController controller, required String label, required String hint, required IconData icon, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.black, size: 24),
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(0), borderSide: BorderSide(color: Colors.black, width: 2.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(0), borderSide: BorderSide(color: Colors.black, width: 2.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(0), borderSide: BorderSide(color: Colors.black, width: 4)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildBrutalButton(Color accent) {
    return GestureDetector(
      onTap: () => controller.createClass(),
      child: Container(
        height: 72,
        decoration: BoxDecoration(color: Colors.black, boxShadow: [BoxShadow(color: accent, offset: const Offset(8, 8))]),
        child: const Center(
          child: Text('INITIALIZE_SESSION_X01', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
        ),
      ),
    );
  }
}
