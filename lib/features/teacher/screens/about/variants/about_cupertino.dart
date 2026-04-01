import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Divider, Color, FontWeight, TextStyle, BorderRadius, BoxShape, BoxDecoration, Border, Widget, EdgeInsets, Column, Row, Expanded, SizedBox, BuildContext, StatelessWidget, Center, ListView, IconData, Icon, CrossAxisAlignment;
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_campus/common/utils/constants/image_strings.dart';

class AboutCupertino extends StatelessWidget {
  const AboutCupertino({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('About'),
        backgroundColor: Color(0xFFF2F2F7),
        border: null,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        children: [
          _buildIosIdentityHeader(),
          const SizedBox(height: 32),
          _buildIosSection('APPLICATION_SPECS', [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('The Smart Campus Attendance Management System is a cross-platform institutional utility designed to optimize academic registries and streamline student tracking protocols via advanced Flutter architecture.', style: const TextStyle(color: Color(0xFF3C3C43), fontSize: 13, height: 1.5)),
            ),
          ]),
          const SizedBox(height: 24),
          _buildIosSection('DEVELOPER_UPLINK', [
            _buildIosDeveloperCell(name: 'Tarun Sisodia', role: 'Lead Architect', icon: CupertinoIcons.chevron_right, color: const Color(0xFF007AFF)),
            const Divider(height: 1, indent: 16, color: Color(0xFFF2F2F7)),
            _buildIosSocialGrid(),
          ]),
          const SizedBox(height: 64),
          const Center(child: Text('© 2025 SmartCampus • Institutional Build', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 11, fontWeight: FontWeight.normal))),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildIosIdentityHeader() {
    return Center(
      child: Column(
        children: [
          Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black12), image: const DecorationImage(image: AssetImage(TImageStrings.appLogo), fit: BoxFit.cover))),
          const SizedBox(height: 16),
          const Text('Smart Campus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: -1)),
          const Text('Institutional Version 0.0.1', style: TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
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

  Widget _buildIosDeveloperCell({required String name, required String role, required IconData icon, required Color color}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(CupertinoIcons.chevron_right_circle_fill, color: color, size: 22)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w600, fontSize: 16)),
                Text(role, style: const TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.bold, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIosSocialGrid() {
    return Column(
      children: [
        _iosSocialCell('Google Profile', 'https://g.dev/tarun1sisodia'),
        const Divider(height: 1, indent: 16, color: Color(0xFFF2F2F7)),
        _iosSocialCell('GitHub Repository', 'https://github.com/tarun1sisodia'),
        const Divider(height: 1, indent: 16, color: Color(0xFFF2F2F7)),
        _iosSocialCell('LinkedIn Professional', 'https://linkedin.com/in/tarun1sisodia'),
      ],
    );
  }

  Widget _iosSocialCell(String label, String url) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () async => await launchUrl(Uri.parse(url)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w400, fontSize: 14))),
            const Icon(CupertinoIcons.chevron_right, size: 14, color: Color(0xFFC7C7CC)),
          ],
        ),
      ),
    );
  }
}
