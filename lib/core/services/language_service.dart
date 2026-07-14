import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../features/home/presentation/controllers/home_controller.dart';
import 'user_pref_service.dart';

/// Reactive language holder, backed by GetX's Translations (see
/// LocalizationString) so `.tr` strings switch via Get.updateLocale().
/// A handful of runtime-computed strings (temperature values, digit
/// localization) still read UserPrefService().isBangla directly since
/// they aren't static labels.
class LanguageService extends GetxService {
  final UserPrefService _prefs = Get.find<UserPrefService>();

  final RxString code = 'bn'.obs;

  /// Called once from Splash after prefs are ready.
  void applySaved() {
    code.value = _prefs.appLanguage;
    Get.updateLocale(Locale(code.value));
  }

  Future<void> setLanguage(String newCode) async {
    if (code.value == newCode) return;
    code.value = newCode;
    await _prefs.setAppLanguage(newCode);

    // Video is language-independent - only the cached type text is stale.
    await _prefs.clearLiveWeatherTypeCache();

    if (Get.isRegistered<HomeController>()) {
      final home = Get.find<HomeController>();
      if (home.lat.value.isNotEmpty) {
        await home.getForecast(home.lat.value, home.lon.value);
        await home.fetchLiveWeather(home.lat.value, home.lon.value);
      }
    }

    // Switches every '.tr' string app-wide and rebuilds GetMaterialApp.
    Get.updateLocale(Locale(newCode));
  }
}
