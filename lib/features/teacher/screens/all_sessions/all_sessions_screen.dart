import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_campus/common/ui_patterns/pattern_scaffold.dart';
import 'package:smart_campus/common/ui_patterns/ui_style_controller.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';
import 'package:smart_campus/features/teacher/controllers/all_sessions_controller.dart';
import 'package:smart_campus/common/utils/constants/sized.dart';
import 'package:smart_campus/features/teacher/screens/all_sessions/variants/all_sessions_corporate.dart';
import 'package:smart_campus/features/teacher/screens/all_sessions/variants/all_sessions_minimalist.dart';
import 'package:smart_campus/features/teacher/screens/all_sessions/variants/all_sessions_glassmorphism.dart';
import 'package:smart_campus/features/teacher/screens/all_sessions/variants/all_sessions_neumorphic.dart';
import 'package:smart_campus/features/teacher/screens/all_sessions/variants/all_sessions_material3.dart';
import 'package:smart_campus/features/teacher/screens/all_sessions/variants/all_sessions_cupertino.dart';
import 'package:smart_campus/features/teacher/screens/all_sessions/variants/all_sessions_cyberpunk.dart';
import 'package:smart_campus/features/teacher/screens/all_sessions/variants/all_sessions_brutalist.dart';
import 'package:smart_campus/features/teacher/screens/all_sessions/variants/all_sessions_academic.dart';
import 'package:smart_campus/features/teacher/screens/all_sessions/variants/all_sessions_fluent.dart';

class AllSessionsScreen extends StatelessWidget {
  final AllSessionsController allSessionsController = Get.put(AllSessionsController());

  AllSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uiController = UIStyleController.instance;

    return Obx(() {
      final style = uiController.currentStyle.value;
      final isSelectionMode = allSessionsController.isSelectionMode.value;

      return PatternScaffold(
        title: isSelectionMode 
            ? '${allSessionsController.selectedSessionIds.length} SELECTED' 
            : 'ACADEMIC_REGISTRY',
        leading: isSelectionMode 
            ? IconButton(icon: const Icon(Icons.close), onPressed: () => allSessionsController.toggleSelectionMode(null))
            : null,
        actions: [
          if (isSelectionMode)
            IconButton(
              onPressed: () => allSessionsController.toggleSelectAll(),
              icon: Icon(allSessionsController.isAllSelected.value ? Icons.select_all : Icons.select_all_outlined),
            ),
          if (!isSelectionMode)
            IconButton(
              onPressed: () => allSessionsController.loadAllSessions(),
              icon: const Icon(Iconsax.refresh),
            ),
        ],
        body: _buildVariant(style),
        bottomNavigationBar: isSelectionMode ? _buildSelectionActionBar(context) : null,
      );
    });
  }

  Widget _buildVariant(UIStyle style) {
    switch (style) {
      case UIStyle.industrialCorporate:
        return AllSessionsCorporate(controller: allSessionsController);
      case UIStyle.softMinimalist:
        return AllSessionsMinimalist(controller: allSessionsController);
      case UIStyle.glassmorphism:
        return AllSessionsGlassmorphism(controller: allSessionsController);
      case UIStyle.neumorphism:
        return AllSessionsNeumorphism(controller: allSessionsController);
      case UIStyle.material3:
        return AllSessionsMaterial3(controller: allSessionsController);
      case UIStyle.cupertinoPro:
        return AllSessionsCupertino(controller: allSessionsController);
      case UIStyle.cyberpunkNeon:
        return AllSessionsCyberpunk(controller: allSessionsController);
      case UIStyle.brutalistBold:
        return AllSessionsBrutalist(controller: allSessionsController);
      case UIStyle.academicClassic:
        return AllSessionsAcademic(controller: allSessionsController);
      case UIStyle.fluentLayered:
        return AllSessionsFluent(controller: allSessionsController);
    }
  }

  Widget _buildSelectionActionBar(BuildContext context) {
    return BottomAppBar(
      height: 70,
      color: Theme.of(context).cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${allSessionsController.selectedSessionIds.length} Selected',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: allSessionsController.selectedSessionIds.isEmpty ? null : () => _showDeleteSelectedConfirmation(context),
              icon: const Icon(Iconsax.trash, size: 18),
              label: const Text('DELETE'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteSelectedConfirmation(BuildContext context) {
    final count = allSessionsController.selectedSessionIds.length;
    Get.defaultDialog(
      title: 'Delete Selected',
      middleText: 'Are you sure you want to delete $count selected sessions? This action is irreversible.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        allSessionsController.deleteSelectedSessions();
        Get.back();
      },
    );
  }
}
