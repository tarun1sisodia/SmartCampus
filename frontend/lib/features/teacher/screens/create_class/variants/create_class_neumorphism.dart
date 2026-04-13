import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/services.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_campus/features/teacher/controllers/class_controller.dart';

class CreateClassNeumorphism extends StatelessWidget {
  final ClassController controller;

  const CreateClassNeumorphism({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFE0E5EC);
    
    return Container(
      color: bgColor,
      child: Obx(() => controller.isLoading.value
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFA3B1C6)))
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            children: [
              _buildNeuHeader(),
              const SizedBox(height: 48),
              const Padding(
                padding: EdgeInsets.only(left: 12, bottom: 12),
                child: Text('STRUCTURAL_PARAMETERS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 1.5)),
              ),
              _buildNeuSection(bgColor, [
                _buildNeuDropdown<dynamic>(
                  label: 'Subject Identifier',
                  icon: Iconsax.book_1,
                  value: controller.selectedSubject.value,
                  items: controller.subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF4D565F))))).toList(),
                  onChanged: (v) => controller.selectedSubject.value = v,
                ),
                const SizedBox(height: 32),
                _buildNeuDropdown<dynamic>(
                  label: 'Course Protocol',
                  icon: Iconsax.teacher,
                  value: controller.selectedCourse.value,
                  items: controller.courses.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF4D565F))))).toList(),
                  onChanged: (v) => controller.selectedCourse.value = v,
                ),
              ]),
              const SizedBox(height: 32),
              _buildNeuSection(bgColor, [
                Row(
                  children: [
                    Expanded(
                      child: _buildNeuField(
                        controller: controller.semesterController,
                        label: 'Semester',
                        hint: '1-8',
                        icon: Iconsax.calendar_tick,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, FilteringTextInputFormatter.allow(RegExp(r'^[1-8]$'))],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildNeuField(
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
              const SizedBox(height: 64),
              _buildNeuButton(bgColor),
              const SizedBox(height: 32),
              const Center(child: Text('REGISTRY_SECURE_V1', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 2))),
              const SizedBox(height: 100),
            ],
          )),
    );
  }

  Widget _buildNeuHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Class', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 40, color: Color(0xFF4D565F), letterSpacing: -1)),
        Text('INITIALIZATION_HUB', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFFA3B1C6), letterSpacing: 2)),
      ],
    );
  }

  Widget _buildNeuSection(Color bg, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
          BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(8, 8), blurRadius: 16),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildNeuDropdown<T>({required String label, required IconData icon, required T? value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 1)),
        const SizedBox(height: 12),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          icon: const Icon(Iconsax.arrow_down_1, color: Color(0xFF4D565F), size: 18),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF4D565F), size: 20),
            filled: true, fillColor: const Color(0xFFE0E5EC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6D5DFC), width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildNeuField({required TextEditingController controller, required String label, required String hint, required IconData icon, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 1)),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF4D565F)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFA3B1C6), fontSize: 13),
            prefixIcon: Icon(icon, color: const Color(0xFF4D565F), size: 20),
            filled: true, fillColor: const Color(0xFFE0E5EC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6D5DFC), width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildNeuButton(Color bg) {
    return GestureDetector(
      onTap: () => controller.createClass(),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
            BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(6, 6), blurRadius: 12),
          ],
        ),
        child: const Center(
          child: Text('INITIALIZE_UPLINK', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF6D5DFC), fontSize: 14, letterSpacing: 2)),
        ),
      ),
    );
  }
}
