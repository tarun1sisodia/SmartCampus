import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Divider, Color, FontWeight, TextStyle, BorderRadius, BoxDecoration, Widget, EdgeInsets, Column, Row, Expanded, SizedBox, BuildContext, StatelessWidget, Center, ListView, IconData, Icon, CrossAxisAlignment, TextFormField, InputDecoration, InputBorder, TextInputType, DropdownMenuItem, DropdownButtonFormField, ValueChanged;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../controllers/class_controller.dart';

class CreateClassCupertino extends StatelessWidget {
  final ClassController controller;

  const CreateClassCupertino({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('New Class'),
        backgroundColor: Color(0xFFF2F2F7),
        border: null,
      ),
      child: Obx(() => controller.isLoading.value
        ? const Center(child: CupertinoActivityIndicator())
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            children: [
              _buildIosHeader(),
              const SizedBox(height: 32),
              _buildIosSection('STRUCTURAL IDENTITY', [
                _buildIosDropdown<dynamic>(
                  label: 'Subject',
                  icon: CupertinoIcons.book,
                  value: controller.selectedSubject.value,
                  items: controller.subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toString(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)))).toList(),
                  onChanged: (v) => controller.selectedSubject.value = v,
                ),
                _buildIosDropdown<dynamic>(
                  label: 'Course',
                  icon: CupertinoIcons.person_2,
                  value: controller.selectedCourse.value,
                  items: controller.courses.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toString(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)))).toList(),
                  onChanged: (v) => controller.selectedCourse.value = v,
                ),
              ]),
              const SizedBox(height: 24),
              _buildIosSection('ACADEMIC ATTRIBUTES', [
                Row(
                  children: [
                    Expanded(
                      child: _buildIosField(
                        controller: controller.semesterController,
                        label: 'Semester',
                        hint: '1-8',
                        icon: CupertinoIcons.calendar,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, FilteringTextInputFormatter.allow(RegExp(r'^[1-8]$'))],
                      ),
                    ),
                    Expanded(
                      child: _buildIosField(
                        controller: controller.sectionController,
                        label: 'Section',
                        hint: 'A-Z',
                        icon: CupertinoIcons.grid,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[A-Z]$'))],
                      ),
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 48),
              _buildIosButton(),
              const SizedBox(height: 32),
              const Center(child: Text('VERSION 1.2.4 • SECURE', style: TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5))),
              const SizedBox(height: 80),
            ],
          )),
    );
  }

  Widget _buildIosHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Initialize', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34, letterSpacing: -1)),
        Text('Academic Stream'.toUpperCase(), style: const TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildIosSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(title, style: const TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.normal, fontSize: 13)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildIosDropdown<T>({required String label, required IconData icon, required T? value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF007AFF), size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<T>(
                  initialValue: value,
                  items: items,
                  onChanged: onChanged,
                  icon: const Icon(CupertinoIcons.chevron_down, size: 14, color: Color(0xFFC7C7CC)),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, indent: 54, color: Color(0xFFF2F2F7)),
      ],
    );
  }

  Widget _buildIosField({required TextEditingController controller, required String label, required String hint, required IconData icon, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF007AFF), size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(color: Color(0xFFC7C7CC), fontSize: 16),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIosButton() {
    return CupertinoButton(
      color: const Color(0xFF007AFF),
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.all(16),
      onPressed: () => controller.createClass(),
      child: const Text('Initialize Registry', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
    );
  }
}
