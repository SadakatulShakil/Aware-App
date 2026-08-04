import 'package:flutter/material.dart';

/// Dynamic theme colors. Always resolve isDark from Theme.of(context) so
/// widgets subscribe to theme changes and rebuild on Get.changeThemeMode():
///   final colors = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);
class AppThemeColors {
  final bool isDark;
  const AppThemeColors._(this.isDark);

  static AppThemeColors of(bool isDark) => AppThemeColors._(isDark);

  // ---- Brand ----
  Color get primary => const Color(0xFF1B5E9E); // DDM blue
  Color get primaryDark => const Color(0xFF10395F);
  Color get secondary => const Color(0xFF2E9E5B);
  Color get emergency => const Color(0xFFD32F2F); // center FAB / SOS

  // ---- Surfaces ----
  Color get scaffoldBg =>
      isDark ? const Color(0xFF0F1418) : const Color(0xFFF4F7FA);
  Color get cardBg => isDark ? const Color(0xFF1C2530) : Colors.white;
  Color get navBarBg => isDark ? const Color(0xFF151C24) : Colors.white;

  // ---- Text ----
  Color get textPrimary =>
      isDark ? Colors.white : const Color(0xFF1A1A2E);
  Color get textAlert =>
      const Color(0xFF1A1A2E);
  Color get textSecondary =>
      isDark ? Colors.white70 : const Color(0xFF5A6472);
  Color get textOnPrimary => Colors.white;

  // ---- Alert severity (DDM legend: Normal / Moderate / Heavy / Extreme) ----
  Color get severityNormal => const Color(0xFF4CAF50);
  Color get severityModerate => const Color(0xFFFFB300);
  Color get severityHeavy => const Color(0xFFFF7043);
  Color get severityExtreme => const Color(0xFFD32F2F);

  Color severityOf(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'moderate':
        return severityModerate;
      case 'heavy':
        return severityHeavy;
      case 'extreme':
        return severityExtreme;
      default:
        return severityNormal;
    }
  }

  // ---- Misc ----
  Color get divider => isDark ? Colors.white12 : const Color(0xFFE3E8EF);
  Color get shimmerBase =>
      isDark ? const Color(0xFF2A3441) : const Color(0xFFE0E0E0);
  Color get shimmerHighlight =>
      isDark ? const Color(0xFF3A4552) : const Color(0xFFF5F5F5);
  Color get headerGradientStart =>
      isDark ? const Color(0xFF10395F) : const Color(0xFF1B5E9E);
  Color get headerGradientEnd =>
      isDark ? const Color(0xFF0B2540) : const Color(0xFF3D82C4);

  // ---- BMD weather header (ported 1:1 — collapsing SliverPersistentHeader) ----
  // AWARE uses its own scaffold background here (not BMD's blues) so the
  // body/collapsed header bar match AWARE's theme instead of looking like BMD.
  Color get scaffoldGradientTop => scaffoldBg;
  Color get scaffoldGradientBottom => scaffoldBg;

  List<Color> get headerGradientColors => const [Color(0x8C1B4871), Color(0x592997E2), Color(0xB316426A)];

  List<double> get headerGradientStops =>
      isDark ? const [0.0, 0.47, 1.0] : const [0.0, 0.40, 1.0];

  // Header text sits on the video/photo background, always white
  // regardless of theme (matches BMD's headerText/headerSecondaryText).
  Color get headerText => Colors.white;
  Color get headerSecondaryText => const Color(0xB3FFFFFF);

  Color get weatherCardText => Colors.white;
  Color get weatherCardTagBg => const Color(0x33FFFFFF);
  Color get weatherCardOverlay =>
      isDark ? Colors.white24 : const Color(0x40FFFFFF);
}
