import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/class_controller.dart';

class CreateClassFluent extends StatelessWidget {
  final ClassController controller;

  const CreateClassFluent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const fluentBg = Color(0xFFF3F3F3);
    
    return Container(
      color: fluentBg,
      child: Obx(() => controller.isLoading.value
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF0078D4)))
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            children: [
              _buildFluentHeader(),
              const SizedBox(height: 32),
              _buildFluentSection('STRUCTURAL IDENTITY', [
                _buildFluentDropdown<dynamic>(
                  label: 'Subject Domain',
                  icon: Iconsax.book_1,
                  value: controller.selectedSubject.value,
                  items: controller.subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF201F1E))))).toList(),
                  onChanged: (v) => controller.selectedSubject.value = v,
                ),
                const SizedBox(height: 24),
                _buildFluentDropdown<dynamic>(
                  label: 'Course Allocation',
                  icon: Iconsax.teacher,
                  value: controller.selectedCourse.value,
                  items: controller.courses.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF201F1E))))).toList(),
                  onChanged: (v) => controller.selectedCourse.value = v,
                ),
              ]),
              const SizedBox(height: 24),
              _buildFluentSection('ACADEMIC PARAMETERS', [
                Row(
                  children: [
                    Expanded(
                      child: _buildFluentField(
                        controller: controller.semesterController,
                        label: 'Semester',
                        hint: '1-8',
                        icon: Iconsax.calendar_tick,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, FilteringTextInputFormatter.allow(RegExp(r'^[1-8]$'))],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFluentField(
                        controller: controller.sectionController,
                        label: 'Section',
                        hint: 'A-Z',
                        icon: Iconsax.grid_5,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[A-Z]$'))],
                      ),
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 48),
              _buildFluentButton(),
              const SizedBox(height: 32),
              const Center(child: Text('RELEASE 1.2.4 • SECURE', style: TextStyle(color: Color(0xFFA19F9D), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5))),
              const SizedBox(height: 100),
            ],
          )),
    );
  }

  Widget _buildFluentHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Inaugurate', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32, color: Color(0xFF201F1E), letterSpacing: -0.5)),
        Text('ACADEMIC_REGISTRY_NODE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0078D4), letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildFluentSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: const TextStyle(color: Color(0xFF605E5C), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildFluentDropdown<T>({required String label, required IconData icon, required T? value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF605E5C))),
        const SizedBox(height: 12),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          icon: const Icon(Iconsax.arrow_down_1, color: Color(0xFF201F1E), size: 18),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF0078D4), size: 20),
            filled: true, fillColor: const Color(0xFFF3F3F3).withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.black.withOpacity(0.05))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.black.withOpacity(0.05))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF0078D4), width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildFluentField({required TextEditingController controller, required String label, required String hint, required IconData icon, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF605E5C))),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF201F1E)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFA19F9D), fontSize: 14),
            prefixIcon: Icon(icon, color: const Color(0xFF0078D4), size: 20),
            filled: true, fillColor: const Color(0xFFF3F3F3).withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.black.withOpacity(0.05))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.black.withOpacity(0.05))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF0078D4), width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildFluentButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: () => controller.createClass(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0078D4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 0,
        ),
        child: const Text('INITIALIZE_SESSION_REGISTRY', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.5)),
      ),
    );
  }
}
