import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'user_pref_service.dart';

class ThemeService extends GetxService {
  final UserPrefService _prefs = Get.find<UserPrefService>();

  final Rx<ThemeMode> mode = ThemeMode.system.obs;

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

  bool get isDark => mode.value == ThemeMode.dark ||
      (mode.value == ThemeMode.system &&
          WidgetsBinding
                  .instance.platformDispatcher.platformBrightness ==
              Brightness.dark);

  ThemeMode _fromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
