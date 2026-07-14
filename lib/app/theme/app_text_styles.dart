import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Central text styles. Font family comes from ThemeData (AnekBangla).
class AppTextStyles {
  AppTextStyles._();

  static TextStyle heading(Color color) => TextStyle(
      fontSize: 22.sp, fontWeight: FontWeight.w700, color: color, height: 1.2);

  static TextStyle sectionTitle(Color color) => TextStyle(
      fontSize: 17.sp, fontWeight: FontWeight.w600, color: color, height: 1.2);

  static TextStyle title(Color color) =>
      TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: color);

  static TextStyle body(Color color) =>
      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: color);

  static TextStyle caption(Color color) =>
      TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: color);

  static TextStyle tempLarge(Color color) => TextStyle(
      fontSize: 58.sp, fontWeight: FontWeight.w600, color: color, height: 1.0);
}
