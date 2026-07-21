import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(false);
  static ThemeData dark() => _build(true);

  static ThemeData _build(bool isDark) {
    final c = AppThemeColors.of(isDark);
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      fontFamily: 'AnekBangla',
      scaffoldBackgroundColor: c.scaffoldBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: c.primary,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: c.textPrimary,
        // Without this, AppBar estimates icon brightness from its own
        // (transparent) backgroundColor, which always reads as "dark" and
        // forces light/white status bar icons - invisible in light mode.
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: c.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerColor: c.divider,
    );
  }
}
