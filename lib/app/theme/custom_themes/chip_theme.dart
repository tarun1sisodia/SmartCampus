import 'package:flutter/material.dart';

class TChipTheme {
  TChipTheme._() {
    //print('TChipTheme initialized');
  }
  static ChipThemeData lightChipThemeData = ChipThemeData(
    disabledColor: Colors.grey.shade100,
    labelStyle: TextStyle(color: Colors.blue),
    selectedColor: Colors.blue,
    checkmarkColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
  );
  static ChipThemeData darkChipThemeData = ChipThemeData(
    disabledColor: Colors.grey.shade100,
    labelStyle: TextStyle(color: Colors.blue),
    checkmarkColor: Colors.white,
    selectedColor: Colors.blue,
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );
}
