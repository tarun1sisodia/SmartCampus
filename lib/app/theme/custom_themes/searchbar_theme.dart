import 'package:flutter/material.dart';

class TSearchbarTheme {
  TSearchbarTheme._();
  static final lightSearchBar = SearchBarThemeData(
    elevation: WidgetStatePropertyAll(0),
    backgroundColor: WidgetStatePropertyAll(Colors.amber),
  );
  static final darkSearchBar = SearchBarThemeData(
    elevation: WidgetStatePropertyAll(0),
    backgroundColor: WidgetStatePropertyAll(Colors.blueGrey),
  );
}
