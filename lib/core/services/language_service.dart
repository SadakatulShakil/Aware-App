import 'dart:async';

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

    // Flip every '.tr' string and rebuild GetMaterialApp FIRST - this is
    // the part the user is actually waiting on, so it must never be
    // queued behind network calls. Data refresh below is fire-and-forget;
    // language-dependent text (forecast, notifications) updates a moment
    // later as those responses land, same as BMD.
    Get.updateLocale(Locale(newCode));

    unawaited(_refreshLanguageDependentData());
  }

  Future<void> _refreshLanguageDependentData() async {
    // Video is language-independent - only the cached type text is stale.
    await _prefs.clearLiveWeatherTypeCache();

    if (!Get.isRegistered<HomeController>()) return;
    final home = Get.find<HomeController>();

    final refreshes = <Future<void>>[
      home.fetchNotifications(),
      home.fetchOngoingBulletins(),
    ];
    if (home.lat.value.isNotEmpty) {
      refreshes.add(home.getForecast(home.lat.value, home.lon.value));
      refreshes.add(home.fetchLiveWeather(home.lat.value, home.lon.value));
    }
    await Future.wait(refreshes);
  }
}
