import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/class_controller.dart';

class CreateClassAcademic extends StatelessWidget {
  final ClassController controller;

  const CreateClassAcademic({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const paperColor = Color(0xFFFAF7F0);
    const inkColor = Color(0xFF2D2E32);
    const accentColor = Color(0xFF8B4513); // Saddle Brown

    return Container(
      color: paperColor,
      child: Obx(() => controller.isLoading.value
        ? const Center(child: CircularProgressIndicator(color: accentColor))
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
            children: [
              _buildScholarHeader(accentColor, inkColor),
              const SizedBox(height: 48),
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 12),
                child: Text('CURRICULAR_PARAMETERS', style: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2, fontFamily: 'Serif')),
              ),
              _buildScholarSection(paperColor, [
                _buildScholarDropdown<dynamic>(
                  label: 'Subject Lexicon',
                  icon: Iconsax.book_1,
                  value: controller.selectedSubject.value,
                  items: controller.subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toString().toUpperCase(), style: TextStyle(color: inkColor, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Serif')))).toList(),
                  onChanged: (v) => controller.selectedSubject.value = v,
                  inkColor: inkColor,
                ),
                const SizedBox(height: 32),
                _buildScholarDropdown<dynamic>(
                  label: 'Faculty Course',
                  icon: Iconsax.teacher,
                  value: controller.selectedCourse.value,
                  items: controller.courses.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toString().toUpperCase(), style: TextStyle(color: inkColor, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Serif')))).toList(),
                  onChanged: (v) => controller.selectedCourse.value = v,
                  inkColor: inkColor,
                ),
              ], inkColor),
              const SizedBox(height: 24),
              _buildScholarSection(paperColor, [
                Row(
                  children: [
                    Expanded(
                      child: _buildScholarField(
                        controller: controller.semesterController,
                        label: 'Semester',
                        hint: '1-8',
                        icon: Iconsax.calendar_tick,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, FilteringTextInputFormatter.allow(RegExp(r'^[1-8]$'))],
                        inkColor: inkColor,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildScholarField(
                        controller: controller.sectionController,
                        label: 'Section',
                        hint: 'A-Z',
                        icon: Iconsax.grid_5,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[A-Z]$'))],
                        inkColor: inkColor,
                      ),
                    ),
                  ],
                ),
              ], inkColor),
              const SizedBox(height: 64),
              _buildScholarButton(inkColor),
              const SizedBox(height: 32),
              const Center(child: Text('EDITION 1.2.4 • ARCHIVAL_SECURE', style: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2, fontFamily: 'Serif'))),
              const SizedBox(height: 100),
            ],
          )),
    );
  }

  Widget _buildScholarHeader(Color accent, Color ink) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Inaugurate', style: TextStyle(color: ink, fontWeight: FontWeight.bold, fontSize: 36, fontFamily: 'Serif')),
        Text('NEW FACULTY REGISTRY', style: TextStyle(color: accent.withValues(alpha: 0.6), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, fontFamily: 'Serif')),
      ],
    );
  }

  Widget _buildScholarSection(Color bg, List<Widget> children, Color ink) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: ink.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: ink.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 4))]),
      child: Column(children: children),
    );
  }

  Widget _buildScholarDropdown<T>({required String label, required IconData icon, required T? value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged, required Color inkColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: inkColor.withValues(alpha: 0.5), fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'Serif')),
        const SizedBox(height: 12),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          dropdownColor: Colors.white,
          icon: Icon(Iconsax.arrow_down_1, color: inkColor.withValues(alpha: 0.6), size: 18),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: inkColor.withValues(alpha: 0.6), size: 20),
            filled: true, fillColor: const Color(0xFFFAF7F0).withValues(alpha: 0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: inkColor.withValues(alpha: 0.1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: inkColor.withValues(alpha: 0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: inkColor.withValues(alpha: 0.4), width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildScholarField({required TextEditingController controller, required String label, required String hint, required IconData icon, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters, required Color inkColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: inkColor.withValues(alpha: 0.5), fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'Serif')),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: TextStyle(color: inkColor, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Serif'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: inkColor.withValues(alpha: 0.2), fontSize: 14, fontFamily: 'Serif'),
            prefixIcon: Icon(icon, color: inkColor.withValues(alpha: 0.6), size: 20),
            filled: true, fillColor: const Color(0xFFFAF7F0).withValues(alpha: 0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: inkColor.withValues(alpha: 0.1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: inkColor.withValues(alpha: 0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: inkColor.withValues(alpha: 0.4), width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildScholarButton(Color ink) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: () => controller.createClass(),
        style: ElevatedButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: const EdgeInsets.all(16),
          elevation: 0,
        ),
        child: const Text('INITIALIZE FACULTY UPLINK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.5, fontFamily: 'Serif')),
      ),
    );
  }
}
