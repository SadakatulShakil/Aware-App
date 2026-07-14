import 'package:flutter/material.dart';

/// Thin TextStyle wrapper so ported BMD weather widgets can call
/// AppFonts.style(...) directly. fontFamily is fixed to AnekBangla
/// (already bundled and set as the app-wide default in AppTheme).
class AppFonts {
  AppFonts._();

  static TextStyle style({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'AnekBangla',
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
