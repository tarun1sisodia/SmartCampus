import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Divider, Icons, InkWell, Color, ColorScheme, Theme, ThemeData, CircleAvatar, TextButton, FontWeight, TextStyle, BorderRadius, Radius, Offset, BoxShape, BoxShadow, BoxDecoration, Border, BorderSide, Widget, EdgeInsets, Column, Row, Expanded, SizedBox, BuildContext, StatelessWidget, Center, ListView, Stack, Positioned, Obx, Get, IconData, Icon, MainAxisAlignment, CrossAxisAlignment, MainAxisSize, VoidCallback, Spacer, Badge, CircleAxis, CircleAvatar, TextSelectionTheme, TextSelectionThemeData, TextFormField, InputDecoration, InputBorder, OutlineInputBorder, FileImage, Chip;
import 'package:iconsax/iconsax.dart';

class ImportCupertino extends StatelessWidget {
  const ImportCupertino({super.key});

  @override
  Widget build(BuildContext context) {
    final RxBool isImporting = false.obs;
    final RxString selectedFileType = 'Excel'.obs;
    final RxBool fileSelected = false.obs;
    final RxString fileName = ''.obs;
    final RxBool replaceData = false.obs;
    final RxBool skipHeader = true.obs;

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Import Data'),
        backgroundColor: Color(0xFFF2F2F7),
        border: null,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        children: [
          _buildIosHeader(),
          const SizedBox(height: 32),
          
          _buildIosSection('FORMAT', [
            Obx(() => _iosFormatRow(selectedFileType)),
          ]),
          
          const SizedBox(height: 24),
          _buildIosSection('ATTACHMENT', [
            _iosFileUpload(fileSelected, fileName, selectedFileType),
          ]),
          
          const SizedBox(height: 24),
          _buildIosSection('SYSTEM_CONFIG', [
            _iosToggle('Overwrite Existing', replaceData),
            const Divider(height: 1, indent: 16, color: Color(0xFFF2F2F7)),
            _iosToggle('Skip Header', skipHeader),
          ]),
          
          const SizedBox(height: 48),
          Obx(() => CupertinoButton.filled(
            onPressed: (!fileSelected.value || isImporting.value) ? null : () {
              isImporting.value = true;
              Future.delayed(const Duration(seconds: 2), () {
                isImporting.value = false;
                Get.back();
              });
            },
            child: isImporting.value 
              ? const CupertinoActivityIndicator(color: Colors.white)
              : const Text('Initiate Uplink', style: TextStyle(fontWeight: FontWeight.w600)),
          )),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildIosHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Import', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34, letterSpacing: -1)),
        Text('BULK_DATA_INGESTION_SYSTEM', style: TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildIosSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(title, style: const TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.normal, fontSize: 12)),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _iosFormatRow(RxString selectedFileType) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _iosFormatCell('Excel', selectedFileType.value == 'Excel', () => selectedFileType.value = 'Excel', const Color(0xFF34C759)),
          const SizedBox(width: 12),
          _iosFormatCell('CSV', selectedFileType.value == 'CSV', () => selectedFileType.value = 'CSV', const Color(0xFF007AFF)),
        ],
      ),
    );
  }

  Widget _iosFormatCell(String label, bool isSelected, VoidCallback onTap, Color color) {
    return Expanded(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isSelected ? color.withValues(alpha: 0.1) : const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(8)),
          child: Text(label, style: TextStyle(color: isSelected ? color : const Color(0xFF8E8E93), fontWeight: FontWeight.w600, fontSize: 14)),
        ),
      ),
    );
  }

  Widget _iosFileUpload(RxBool fileSelected, RxString fileName, RxString format) {
    return Obx(() => fileSelected.value 
      ? Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(CupertinoIcons.doc_text_fill, color: Color(0xFF007AFF), size: 32),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                Text(fileName.value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                Text('STAT_READY'.toUpperCase(), style: const TextStyle(color: Color(0xFF34C759), fontWeight: FontWeight.bold, fontSize: 11)),
              ])),
              CupertinoButton(padding: EdgeInsets.zero, onPressed: () { fileSelected.value = false; fileName.value = ''; }, child: const Icon(CupertinoIcons.xmark_circle_fill, color: Color(0xFF8E8E93))),
            ],
          ),
        )
      : CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 32),
          onPressed: () { fileSelected.value = true; fileName.value = 'DATA_UPLINK.${format.value.toUpperCase()}'; },
          child: Center(
            child: Column(
              children: const [
                Icon(CupertinoIcons.cloud_upload_fill, color: Color(0xFF007AFF), size: 32),
                SizedBox(height: 8),
                Text('Select Payload', style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.normal, fontSize: 13)),
              ],
            ),
          ),
        )
    );
  }

  Widget _iosToggle(String label, RxBool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
          Obx(() => CupertinoSwitch(value: value.value, onChanged: (v) => value.value = v)),
        ],
      ),
    );
  }
}
