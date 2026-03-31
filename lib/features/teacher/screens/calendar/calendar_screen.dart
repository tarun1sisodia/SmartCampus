import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/calendar_controller.dart';
import '../../../common/ui_patterns/pattern_scaffold.dart';
import '../../../common/ui_patterns/ui_style_controller.dart';
import '../../../common/ui_patterns/ui_style.dart';
import 'variants/calendar/calendar_corporate.dart';
import 'variants/calendar/calendar_minimalist.dart';
import 'variants/calendar/calendar_glassmorphism.dart';
import 'variants/calendar/calendar_neumorphic.dart';
import 'variants/calendar/calendar_material3.dart';
import 'variants/calendar/calendar_cupertino.dart';
import 'variants/calendar/calendar_cyberpunk.dart';
import 'variants/calendar/calendar_brutalist.dart';
import 'variants/calendar/calendar_academic.dart';
import 'variants/calendar/calendar_fluent.dart';
import '../../../common/utils/constants/sized.dart';

class CalendarScreen extends StatelessWidget {
  final CalendarController controller = Get.put(CalendarController());

  CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uiController = UIStyleController.instance;

    return Obx(() {
      final style = uiController.currentStyle.value;
      
      return PatternScaffold(
        title: 'ACADEMIC CALENDAR',
        actions: [
          IconButton(
            onPressed: () => _showFilterBottomSheet(context),
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Schedule',
          ),
          IconButton(
            onPressed: () => controller.refreshData(),
            icon: const Icon(Iconsax.refresh),
            tooltip: 'Refresh',
          ),
        ],
        body: _buildVariant(style),
      );
    });
  }

  Widget _buildVariant(UIStyle style) {
    switch (style) {
      case UIStyle.industrialCorporate:
        return CalendarCorporate(controller: controller);
      case UIStyle.softMinimalist:
        return CalendarMinimalist(controller: controller);
      case UIStyle.glassmorphism:
        return CalendarGlassmorphism(controller: controller);
      case UIStyle.neumorphism:
        return CalendarNeumorphism(controller: controller);
      case UIStyle.material3:
        return CalendarMaterial3(controller: controller);
      case UIStyle.cupertinoPro:
        return CalendarCupertino(controller: controller);
      case UIStyle.cyberpunkNeon:
        return CalendarCyberpunk(controller: controller);
      case UIStyle.brutalistBold:
        return CalendarBrutalist(controller: controller);
      case UIStyle.academicClassic:
        return CalendarAcademic(controller: controller);
      case UIStyle.fluentLayered:
        return CalendarFluent(controller: controller);
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(TSizes.cardRadiusLg)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter Schedule', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: TSizes.lg),
              Obx(() => SwitchListTile(
                    title: const Text('Show All Teachers'),
                    value: controller.showAllSessions.value,
                    onChanged: (v) {
                      controller.showAllSessions.value = v;
                      if (v) controller.showOnlyMyClasses.value = false;
                    },
                  )),
              Obx(() => SwitchListTile(
                    title: const Text('Show Only My Classes'),
                    value: controller.showOnlyMyClasses.value,
                    onChanged: controller.showAllSessions.value ? null : (v) => controller.showOnlyMyClasses.value = v,
                  )),
              const Divider(),
              _buildDropdownFilter(context, 'Course', controller.selectedCourse, controller.availableCourses),
              _buildDropdownFilter(context, 'Semester', controller.selectedSemester, controller.availableSemesters.map((s) => s.toString()).toList(), isInt: true),
              const SizedBox(height: TSizes.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.showAllSessions.value = false;
                    controller.showOnlyMyClasses.value = false;
                    controller.selectedCourse.value = null;
                    controller.selectedSemester.value = null;
                    Get.back();
                  },
                  child: const Text('Reset Filters'),
                ),
              ),
              const SizedBox(height: TSizes.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownFilter(BuildContext context, String label, Rx<dynamic> selected, List<String> items, {bool isInt = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Obx(() => DropdownButton<dynamic>(
                isExpanded: true,
                value: selected.value,
                onChanged: controller.showAllSessions.value ? null : (v) => selected.value = v,
                items: [
                  DropdownMenuItem(value: null, child: Text('All ${label}s')),
                  ...items.map((item) => DropdownMenuItem(value: isInt ? int.parse(item) : item, child: Text(isInt ? 'Semester $item' : item))),
                ],
              )),
        ],
      ),
    );
  }
}
