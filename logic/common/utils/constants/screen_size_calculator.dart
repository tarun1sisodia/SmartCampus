// =============================================================
// screen_size_calculator.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/common/utils/constants/screen_size_calculator.dart)
// =============================================================

// class TDeviceUtils : screenHeight(context) / screenWidth(context) -> MediaQuery size

// class TScreenResponsive :
//   isMobile(context)  -> width <= 500
//   isTablet(context)  -> 500 < width < 1024
//   isDesktop(context) -> width >= 1024

// extension TScreenSize on BuildContext :
//   height / width shortcuts + heightPercent10..90, widthPercent10..90 (screen fraction helpers)
//   dynamicWidth / dynamicHeight = 1% of screen
//   isMobile / isTablet / isDesktop same rules as above

// class TDeviceScreen : more static wrappers around MediaQuery width/height
