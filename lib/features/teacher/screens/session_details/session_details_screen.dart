import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/session_details_controller.dart';
import '../../../common/ui_patterns/pattern_scaffold.dart';
import '../../../common/ui_patterns/ui_style_controller.dart';
import '../../../common/ui_patterns/ui_style.dart';
import 'variants/session_details/session_details_corporate.dart';
import 'variants/session_details/session_details_minimalist.dart';
import 'variants/session_details/session_details_glassmorphism.dart';
import 'variants/session_details/session_details_neumorphic.dart';
import 'variants/session_details/session_details_material3.dart';
import 'variants/session_details/session_details_cupertino.dart';
import 'variants/session_details/session_details_cyberpunk.dart';
import 'variants/session_details/session_details_brutalist.dart';
import 'variants/session_details/session_details_academic.dart';
import 'variants/session_details/session_details_fluent.dart';

class SessionDetailsScreen extends StatelessWidget {
  final SessionDetailsController controller = Get.put(SessionDetailsController());

  SessionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uiController = UIStyleController.instance;
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;

    if (args == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Session details missing', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => Get.back(), child: const Text('Go Back')),
            ],
          ),
        ),
      );
    }

    final String sessionId = args['sessionId'];
    final Map<String, dynamic> classDetails = args['classDetails'];

    return Obx(() {
      final style = uiController.currentStyle.value;

      return PatternScaffold(
        title: 'SESSION_LEDGER',
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: () => controller.refreshData(sessionId),
          ),
        ],
        body: _buildVariant(style, classDetails),
      );
    });
  }

  Widget _buildVariant(UIStyle style, Map<String, dynamic> classDetails) {
    switch (style) {
      case UIStyle.industrialCorporate:
        return SessionDetailsCorporate(controller: controller, classDetails: classDetails);
      case UIStyle.softMinimalist:
        return SessionDetailsMinimalist(controller: controller, classDetails: classDetails);
      case UIStyle.glassmorphism:
        return SessionDetailsGlassmorphism(controller: controller, classDetails: classDetails);
      case UIStyle.neumorphism:
        return SessionDetailsNeumorphism(controller: controller, classDetails: classDetails);
      case UIStyle.material3:
        return SessionDetailsMaterial3(controller: controller, classDetails: classDetails);
      case UIStyle.cupertinoPro:
        return SessionDetailsCupertino(controller: controller, classDetails: classDetails);
      case UIStyle.cyberpunkNeon:
        return SessionDetailsCyberpunk(controller: controller, classDetails: classDetails);
      case UIStyle.brutalistBold:
        return SessionDetailsBrutalist(controller: controller, classDetails: classDetails);
      case UIStyle.academicClassic:
        return SessionDetailsAcademic(controller: controller, classDetails: classDetails);
      case UIStyle.fluentLayered:
        return SessionDetailsFluent(controller: controller, classDetails: classDetails);
    }
  }
}
