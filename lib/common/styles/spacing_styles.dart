import '../utils/constants/sized.dart';
import 'package:flutter/material.dart';

class TSpacingStyles {
  TSpacingStyles._() {
    //print('TSpacingStyles initialized');
  }
  static const EdgeInsetsGeometry paddingWithAppBarHeight = EdgeInsets.only(
    top: TSizes.appBarHeight,
    left: TSizes.defaultSpace,
    right: TSizes.defaultSpace,
    bottom: TSizes.defaultSpace,
  );
}
