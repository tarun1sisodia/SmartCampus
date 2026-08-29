// =============================================================
// theme.dart (app/theme)  ->  ALGORITHM ONLY (source: frontend/lib/app/theme/theme.dart)
// Builds a full ThemeData from a ThemeConfig palette.
// =============================================================

// class TAppTheme (static only) :
//   createTheme(ThemeConfig config) :
//     brightness = config.isDark ? dark : light
//     return ThemeData(material3, font 'Inter', brightness, primary color, scaffold background)
//       and attach every component sub-theme:
//         textTheme            <- TtextTheme.createTextTheme(text colors)
//         inputDecorationTheme <- TTextFieldTheme.createInputDecorationTheme(...)
//         appBarTheme / bottomSheetTheme / checkboxTheme / chipTheme /
//         elevatedButtonTheme / searchBarTheme / cardTheme  <- each custom_themes file
//     (+ a darkTheme/lightTheme convenience pair selecting from AppThemes list)
