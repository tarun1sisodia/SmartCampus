import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/class_controller.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';

class CreateClassScreen extends StatelessWidget {
  final classController = Get.find<ClassController>();

  CreateClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.slate50,
      appBar: AppBar(
        title: Text(
          'CREATE NEW CLASS',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
      ),
      body: Obx(
        () {
          return classController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'STRUCTURAL DETAILS',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5, color: TColors.slate600),
                      ),
                      const SizedBox(height: 24),

                      // 1. Subject & Course Section
                      _buildFormSection(
                        children: [
                          _buildDropdown<dynamic>(
                            label: 'SUBJECT',
                            icon: Iconsax.book_1,
                            value: classController.selectedSubject.value,
                            items: classController.subjects.map((subject) {
                              return DropdownMenuItem(
                                value: subject,
                                child: Text(subject.name.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (value) => classController.selectedSubject.value = value,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown<dynamic>(
                            label: 'COURSE',
                            icon: Iconsax.teacher,
                            value: classController.selectedCourse.value,
                            items: classController.courses.map((course) {
                              return DropdownMenuItem(
                                value: course,
                                child: Text(course.name.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (value) => classController.selectedCourse.value = value,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 2. Academic Metrics
                      _buildFormSection(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextFormField(
                                  controller: classController.semesterController,
                                  label: 'SEMESTER',
                                  hint: '1-8',
                                  icon: Iconsax.calendar_tick,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    FilteringTextInputFormatter.allow(RegExp(r'^[1-8]$')),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextFormField(
                                  controller: classController.sectionController,
                                  label: 'SECTION',
                                  hint: 'A-Z',
                                  icon: Iconsax.grid_5,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^[A-Z]$')),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 48),

                      // 3. Execution Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => classController.createClass(),
                          child: const Text('CREATE CLASS'),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      const Center(
                        child: Text(
                          'SESSION WILL BE INITIALIZED UPON COMPLETION.',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: TColors.slate500, letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildFormSection({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: TColors.slate300, width: 1.5),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDropdown<T>({required String label, required IconData icon, required T? value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: TColors.slate600, letterSpacing: 1.0)),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          icon: const Icon(Iconsax.arrow_down_1, color: TColors.executiveNavy),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: TColors.executiveNavy, size: 20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({required TextEditingController controller, required String label, required String hint, required IconData icon, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: TColors.slate600, letterSpacing: 1.0)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: TColors.executiveNavy, size: 20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
