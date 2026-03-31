import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/class_controller.dart';

class CreateClassMinimalist extends StatelessWidget {
  final ClassController controller;

  const CreateClassMinimalist({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Obx(() => controller.isLoading.value
        ? const Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            children: [
              const Text('Create Class', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 32, color: Colors.black87, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Text('Define the parameters for your new academic session.', style: TextStyle(color: Colors.grey[500], fontSize: 13, height: 1.5)),
              const SizedBox(height: 48),
              _buildMinDropdown<dynamic>(
                label: 'Subject',
                icon: Iconsax.book_1,
                value: controller.selectedSubject.value,
                items: controller.subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toString(), style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)))).toList(),
                onChanged: (v) => controller.selectedSubject.value = v,
              ),
              const SizedBox(height: 32),
              _buildMinDropdown<dynamic>(
                label: 'Course',
                icon: Iconsax.teacher,
                value: controller.selectedCourse.value,
                items: controller.courses.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toString(), style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)))).toList(),
                onChanged: (v) => controller.selectedCourse.value = v,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildMinField(
                      controller: controller.semesterController,
                      label: 'Semester',
                      hint: '1 - 8',
                      icon: Iconsax.calendar_tick,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, FilteringTextInputFormatter.allow(RegExp(r'^[1-8]$'))],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: _buildMinField(
                      controller: controller.sectionController,
                      label: 'Section',
                      hint: 'A - Z',
                      icon: Iconsax.grid_5,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[A-Z]$'))],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 64),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: TextButton(
                  onPressed: () => controller.createClass(),
                  style: TextButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.all(16)),
                  child: const Text('Initialize Class', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 32),
              Center(child: Text('All data is encrypted and synced.', style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.w500))),
            ],
          )),
    );
  }

  Widget _buildMinDropdown<T>({required String label, required IconData icon, required T? value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black54)),
        ),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          icon: const Icon(Iconsax.arrow_down_1, color: Colors.black26, size: 18),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.black, size: 20),
            filled: true, fillColor: const Color(0xFFFBFBFB),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!, width: 1)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!, width: 1)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black, width: 1)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildMinField({required TextEditingController controller, required String label, required String hint, required IconData icon, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black54)),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.black, size: 20),
            filled: true, fillColor: const Color(0xFFFBFBFB),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!, width: 1)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!, width: 1)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black, width: 1)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }
}
