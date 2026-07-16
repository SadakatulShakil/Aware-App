import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'user_pref_service.dart';

class ThemeService extends GetxService {
  final UserPrefService _prefs = Get.find<UserPrefService>();

  final Rx<ThemeMode> mode = ThemeMode.dark.obs;

  /// Called once from Splash after prefs are ready.
  void applySaved() {
    mode.value = _fromString(_prefs.themeMode);
    Get.changeThemeMode(mode.value);
  }

  Future<void> setMode(ThemeMode newMode) async {
    mode.value = newMode;
    Get.changeThemeMode(newMode);
    await _prefs.setThemeMode(newMode.name);
  }

  bool get isDark => mode.value == ThemeMode.dark;

  ThemeMode _fromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.dark;
    }
  }
}
