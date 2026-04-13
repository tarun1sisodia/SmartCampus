import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeviceUtility {
  DeviceUtility._() {
    //print('DeviceUtility initialized');
  }
  // Hides the keyboard
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  // Sets the status bar color
  static void setStatusBarColor(Color color) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: color),
    );
  }

  // Checks if the device is in landscape orientation
  static bool isLandscapeOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  // Checks if the device is in portrait orientation
  static bool isPortraitOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  // Enables or disables full screen mode
  static void setFullScreen(bool enable) {
    SystemChrome.setEnabledSystemUIMode(
      enable ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  // Gets the screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Gets the screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // Gets the device pixel ratio
  static double getPixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  // Gets the status bar height
  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  // Gets the bottom navigation bar height
  static double getBottomNavigationBarHeight() {
    return kBottomNavigationBarHeight;
  }

  // Gets the app bar height
  static double getAppBarHeight() {
    return kToolbarHeight;
  }

  // Sets the preferred orientations
  static void setPreferredOrientations(List<DeviceOrientation> orientations) {
    SystemChrome.setPreferredOrientations(orientations);
  }

  // Shows the status bar
  static void showStatusBar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
  }

  // Hides the status bar
  static void hideStatusBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  // Checks if the device is a tablet
  static bool isTablet(BuildContext context) {
    double shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide > 600;
  }

  // Checks if the device is a mobile
  static bool isMobile(BuildContext context) {
    double shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide < 600;
  }

  // Checks if the device has an internet connection
  /*static Future<bool> hasInternetConnection() async {
    final connectivity = await Connectivity().checkConnectivity();
    return connectivity != ConnectivityResult.none;
  }*/

  // Checks if the device is running iOS
  static bool isIOS() {
    return Platform.isIOS;
  }

  // Checks if the device is running Android
  static bool isAndroid() {
    return Platform.isAndroid;
  }

  // Launches a URL
  // static Future<void> launchUrl(String url) async {
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw Exception('Could not launch $url');
  //   }
  // }

  // Gets the keyboard height
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  // Checks if the keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  // Vibrates the device
  // static Future<void> vibrate() async {
  //   if (await Vibration.hasVibrator()) {
  //     await Vibration.vibrate(duration: 200);
  //   } else {
  //     throw Exception('Device does not have a vibrator');
  //   }
  // }

  // Vibrates the device with a pattern
  // static Future<void> vibrateWithPattern(List<int> pattern) async {
  //   if (await Vibration.hasVibrator()) {
  //     await Vibration.vibrate(pattern: pattern);
  //   } else {
  //     throw Exception('Device does not have a vibrator');
  //   }
  // }

  // // Checks if the device has a vibrator
  // static Future<bool> hasVibrator() async {
  //   return await Vibration.hasVibrator();
  // }
}
