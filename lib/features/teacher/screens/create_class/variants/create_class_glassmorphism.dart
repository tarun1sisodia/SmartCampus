import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/class_controller.dart';

class CreateClassGlassmorphism extends StatelessWidget {
  final ClassController controller;

  const CreateClassGlassmorphism({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              children: [
                _buildGlassHeader(),
                const SizedBox(height: 48),
                const Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 12),
                  child: Text('STRUCTURAL DEFINITION', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2)),
                ),
                _glassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildGlassDropdown<dynamic>(
                        label: 'SUBJECT',
                        icon: Iconsax.book_1,
                        value: controller.selectedSubject.value,
                        items: controller.subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)))).toList(),
                        onChanged: (v) => controller.selectedSubject.value = v,
                      ),
                      const SizedBox(height: 24),
                      _buildGlassDropdown<dynamic>(
                        label: 'COURSE',
                        icon: Iconsax.teacher,
                        value: controller.selectedCourse.value,
                        items: controller.courses.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)))).toList(),
                        onChanged: (v) => controller.selectedCourse.value = v,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _glassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildGlassField(
                          controller: controller.semesterController,
                          label: 'SEMESTER',
                          hint: '1-8',
                          icon: Iconsax.calendar_tick,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, FilteringTextInputFormatter.allow(RegExp(r'^[1-8]$'))],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildGlassField(
                          controller: controller.sectionController,
                          label: 'SECTION',
                          hint: 'A-Z',
                          icon: Iconsax.grid_5,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[A-Z]$'))],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                _buildGlassButton(),
                const SizedBox(height: 32),
                Center(child: Text('UPLINK SECURE', style: TextStyle(color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2))),
                const SizedBox(height: 100),
              ],
            )),
      ),
    );
  }

  Widget _buildGlassHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Initialize', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 36, letterSpacing: -1)),
        Text('NEW ACADEMIC STREAM', style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
      ],
    );
  }

  Widget _glassContainer({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGlassDropdown<T>({required String label, required IconData icon, required T? value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
        const SizedBox(height: 12),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          dropdownColor: Colors.white,
          icon: const Icon(Iconsax.arrow_down_1, color: Colors.white, size: 18),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white, size: 20),
            filled: true, fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassField({required TextEditingController controller, required String label, required String hint, required IconData icon, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.white, size: 20),
            filled: true, fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: InkWell(
            onTap: () => controller.createClass(),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Center(
                child: Text('INITIALIZE STREAM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
