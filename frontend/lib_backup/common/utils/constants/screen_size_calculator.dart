import 'package:flutter/material.dart';

//it is not being used anywhere
class TDeviceUtils {
  TDeviceUtils._() {
    //print('TDeviceUtils initialized');
  }
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
}
//it is not being used anywhere
class TScreenResponsive {
  TScreenResponsive._();
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <= 500;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1024 &&
      MediaQuery.of(context).size.width > 500;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;
}
//it is not being used anywhere
extension TScreenSize on BuildContext {
  // Screen Height Percentages
  double get height => MediaQuery.of(this).size.height;
  double get width => MediaQuery.of(this).size.width;

  double get heightPercent10 => height * 0.1;
  double get heightPercent20 => height * 0.2;
  double get heightPercent30 => height * 0.3;
  double get heightPercent40 => height * 0.4;
  double get heightPercent50 => height * 0.5;
  double get heightPercent60 => height * 0.6;
  double get heightPercent70 => height * 0.7;
  double get heightPercent80 => height * 0.8;
  double get heightPercent90 => height * 0.9;

  // Screen Width Percentages
  double get widthPercent10 => width * 0.1;
  double get widthPercent20 => width * 0.2;
  double get widthPercent30 => width * 0.3;
  double get widthPercent40 => width * 0.4;
  double get widthPercent50 => width * 0.5;
  double get widthPercent60 => width * 0.6;
  double get widthPercent70 => width * 0.7;
  double get widthPercent80 => width * 0.8;
  double get widthPercent90 => width * 0.9;

  // Dynamic Spacing
  double get dynamicWidth => width / 100;
  double get dynamicHeight => height / 100;

  // Device Type Check
  bool get isMobile => width <= 500;
  bool get isTablet => width < 1024 && width > 500;
  bool get isDesktop => width >= 1024;
}

class TDeviceScreen {
  TDeviceScreen._();
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getPixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static double statusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static double bottomNavigationBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  static double getAppBarHeight() {
    return kToolbarHeight;
  }
}
