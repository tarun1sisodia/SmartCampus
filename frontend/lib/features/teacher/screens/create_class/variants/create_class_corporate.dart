import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_campus/features/teacher/controllers/class_controller.dart';

class CreateClassCorporate extends StatelessWidget {
  final ClassController controller;

  const CreateClassCorporate({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Obx(() => controller.isLoading.value
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            children: [
              const Text('STRUCTURAL_DEFINITION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF64748B), letterSpacing: 2)),
              const SizedBox(height: 24),
              _buildFormSection([
                _buildDropdown<dynamic>(
                  label: 'SUBJECT_ID',
                  icon: Iconsax.book_1,
                  value: controller.selectedSubject.value,
                  items: controller.subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)))).toList(),
                  onChanged: (v) => controller.selectedSubject.value = v,
                ),
                const SizedBox(height: 20),
                _buildDropdown<dynamic>(
                  label: 'COURSE_ID',
                  icon: Iconsax.teacher,
                  value: controller.selectedCourse.value,
                  items: controller.courses.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)))).toList(),
                  onChanged: (v) => controller.selectedCourse.value = v,
                ),
              ]),
              const SizedBox(height: 24),
              _buildFormSection([
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        controller: controller.semesterController,
                        label: 'SEM_OFFSET',
                        hint: 'RANGE: 1-8',
                        icon: Iconsax.calendar_tick,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, FilteringTextInputFormatter.allow(RegExp(r'^[1-8]$'))],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildField(
                        controller: controller.sectionController,
                        label: 'SEC_NODE',
                        hint: 'RANGE: A-Z',
                        icon: Iconsax.grid_5,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[A-Z]$'))],
                      ),
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => controller.createClass(),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), elevation: 0),
                  child: const Text('INITIALIZE_CLASS_STREAM', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ),
              ),
              const SizedBox(height: 24),
              const Center(child: Text('SESSION_COMMIT_AUTO_ON_COMPLETE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF94A3B8), letterSpacing: 1))),
            ],
          )),
    );
  }

  Widget _buildFormSection(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0), width: 2)),
      child: Column(children: children),
    );
  }

  Widget _buildDropdown<T>({required String label, required IconData icon, required T? value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF64748B), letterSpacing: 1)),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          icon: const Icon(Iconsax.arrow_down_1, color: Color(0xFF0F172A), size: 18),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF0F172A), size: 20),
            filled: true, fillColor: const Color(0xFFF8FAFC),
            border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
            enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
            focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Color(0xFF0F172A), width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildField({required TextEditingController controller, required String label, required String hint, required IconData icon, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF64748B), letterSpacing: 1)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF0F172A), size: 20),
            filled: true, fillColor: const Color(0xFFF8FAFC),
            border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
            enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
            focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Color(0xFF0F172A), width: 2)),
          ),
        ),
      ],
    );
  }
}
