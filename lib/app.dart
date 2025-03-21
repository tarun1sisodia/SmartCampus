import 'package:attedance__/features/authentication/screens/onboarding/onboarding.dart';
import 'package:attedance__/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      //It will detect theme and apply on system.
      themeMode: ThemeMode.system,
      darkTheme: TAppTheme.darkTheme,
      theme: TAppTheme.lightTheme,
      home: Onboarding(),
      debugShowCheckedModeBanner: false,
    );
  }
}
