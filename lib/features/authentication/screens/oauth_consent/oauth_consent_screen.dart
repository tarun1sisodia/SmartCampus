import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../../../common/ui_patterns/ui_style_controller.dart';
import 'variants/oauth_consent_academic.dart';
import 'variants/oauth_consent_brutalist.dart';
import 'variants/oauth_consent_corporate.dart';
import 'variants/oauth_consent_cupertino.dart';
import 'variants/oauth_consent_cyberpunk.dart';
import 'variants/oauth_consent_fluent.dart';
import 'variants/oauth_consent_glassmorphism.dart';
import 'variants/oauth_consent_material3.dart';
import 'variants/oauth_consent_minimalist.dart';
import 'variants/oauth_consent_neumorphism.dart';

class OAuthConsentScreen extends StatelessWidget {
  const OAuthConsentScreen({
    super.key,
    required this.appName,
    required this.scopes,
  });

  final String appName;
  final List<String> scopes;

  @override
  Widget build(BuildContext context) {
    final uiController = UIStyleController.instance;

    return Obx(() {
      final style = uiController.currentStyle.value;
      return Scaffold(
        body: _buildVariant(style),
      );
    });
  }

  Widget _buildVariant(UIStyle style) {
    switch (style) {
      case UIStyle.industrialCorporate:
        return OAuthConsentCorporate(appName: appName, scopes: scopes);
      case UIStyle.softMinimalist:
        return OAuthConsentMinimalist(appName: appName, scopes: scopes);
      case UIStyle.glassmorphism:
        return OAuthConsentGlassmorphism(appName: appName, scopes: scopes);
      case UIStyle.neumorphism:
        return OAuthConsentNeumorphism(appName: appName, scopes: scopes);
      case UIStyle.material3:
        return OAuthConsentMaterial3(appName: appName, scopes: scopes);
      case UIStyle.cupertinoPro:
        return OAuthConsentCupertino(appName: appName, scopes: scopes);
      case UIStyle.cyberpunkNeon:
        return OAuthConsentCyberpunk(appName: appName, scopes: scopes);
      case UIStyle.brutalistBold:
        return OAuthConsentBrutalist(appName: appName, scopes: scopes);
      case UIStyle.academicClassic:
        return OAuthConsentAcademic(appName: appName, scopes: scopes);
      case UIStyle.fluentLayered:
        return OAuthConsentFluent(appName: appName, scopes: scopes);
    }
  }
}
