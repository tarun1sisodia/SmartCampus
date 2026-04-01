import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/class_controller.dart';

class CreateClassMaterial3 extends StatelessWidget {
  final ClassController controller;

  const CreateClassMaterial3({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      color: theme.colorScheme.surface,
      child: Obx(() => controller.isLoading.value
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            children: [
              _buildM3Header(theme),
              const SizedBox(height: 32),
              _buildM3Section(theme, 'Course information', [
                _buildM3Dropdown<dynamic>(
                  label: 'Subject',
                  icon: Iconsax.book_1,
                  value: controller.selectedSubject.value,
                  items: controller.subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)))).toList(),
                  onChanged: (v) => controller.selectedSubject.value = v,
                ),
                const SizedBox(height: 24),
                _buildM3Dropdown<dynamic>(
                  label: 'Course',
                  icon: Iconsax.teacher,
                  value: controller.selectedCourse.value,
                  items: controller.courses.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)))).toList(),
                  onChanged: (v) => controller.selectedCourse.value = v,
                ),
              ]),
              const SizedBox(height: 24),
              _buildM3Section(theme, 'Academic schedule', [
                Row(
                  children: [
                    Expanded(
                      child: _buildM3Field(
                        controller: controller.semesterController,
                        label: 'Semester',
                        hint: '1 - 8',
                        icon: Iconsax.calendar_tick,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, FilteringTextInputFormatter.allow(RegExp(r'^[1-8]$'))],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildM3Field(
                        controller: controller.sectionController,
                        label: 'Section',
                        hint: 'A - Z',
                        icon: Iconsax.grid_5,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[A-Z]$'))],
                      ),
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 48),
              _buildM3Button(theme),
              const SizedBox(height: 32),
              Center(child: Text('Version 1.2.4 • Secure Session', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold))),
              const SizedBox(height: 80),
            ],
          )),
    );
  }

  Widget _buildM3Header(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Create Class', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 4),
        Text('Establish a new academic registry node.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildM3Section(ThemeData theme, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(title, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        ),
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: items),
          ),
        ),
      ],
    );
  }

  Widget _buildM3Dropdown<T>({required String label, required IconData icon, required T? value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 12),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          icon: const Icon(Iconsax.arrow_down_1, size: 18),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            filled: true, fillColor: Colors.white.withValues(alpha: 0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildM3Field({required TextEditingController controller, required String label, required String hint, required IconData icon, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            filled: true, fillColor: Colors.white.withValues(alpha: 0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildM3Button(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: FilledButton(
        onPressed: () => controller.createClass(),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: const Text('Initialize Class', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
