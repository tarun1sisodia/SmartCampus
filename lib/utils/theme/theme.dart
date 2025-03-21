import 'package:attedance__/utils/theme/custom_themes/appbar_theme.dart';
import 'package:attedance__/utils/theme/custom_themes/bottom_sheet_theme.dart';
import 'package:attedance__/utils/theme/custom_themes/checkbox_theme.dart';
import 'package:attedance__/utils/theme/custom_themes/chip_theme.dart';
import 'package:attedance__/utils/theme/custom_themes/elevated_button_theme.dart';
import 'package:attedance__/utils/theme/custom_themes/searchbar_theme.dart';
import 'package:attedance__/utils/theme/custom_themes/text_field_theme.dart';
import 'package:attedance__/utils/theme/custom_themes/text_theme.dart';
import 'package:flutter/material.dart';

class TAppTheme {
  TAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: Colors.blueAccent,
    scaffoldBackgroundColor: Colors.white,
    textTheme: TtextTheme.lighttextTheme,
    inputDecorationTheme: TTextFieldTheme.lightInputDecoration,
    appBarTheme: TAppbarTheme.lightAppBarTheme,
    bottomSheetTheme: TBottomSheetTheme.lightBottomSheetTheme,
    checkboxTheme: TCheckboxTheme.lightCheckBoxTheme,
    chipTheme: TChipTheme.lightChipThemeData,
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButton,
    searchBarTheme: TSearchbarTheme.lightSearchBar,
    iconTheme: IconThemeData(color: Colors.black)
  );
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.black,
    textTheme: TtextTheme.darktextTheme,
    inputDecorationTheme: TTextFieldTheme.darkInputDecoration,
    appBarTheme: TAppbarTheme.darkAppBarTheme,
    bottomSheetTheme: TBottomSheetTheme.darkBottomSheetTheme,
    checkboxTheme: TCheckboxTheme.darkCheckBoxTheme,
    chipTheme: TChipTheme.darkChipThemeData,
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButton,
    searchBarTheme: TSearchbarTheme.darkSearchBar,
    iconTheme: IconThemeData(color: Colors.white)
  );
}
