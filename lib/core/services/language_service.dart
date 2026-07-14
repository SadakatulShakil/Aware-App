import 'package:get/get.dart';

import '../../features/home/presentation/controllers/home_controller.dart';
import 'user_pref_service.dart';

/// Reactive language holder. AWARE has no Get.locale/translations - every
/// string is an inline bn/en ternary reading UserPrefService().isBangla.
/// This service exists only so widgets/Settings can react to a change and
/// so the forecast (Accept-Language-driven) gets refetched.
class LanguageService extends GetxService {
  final UserPrefService _prefs = Get.find<UserPrefService>();

  final RxString code = 'bn'.obs;

  /// Called once from Splash after prefs are ready.
  void applySaved() {
    code.value = _prefs.appLanguage;
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

    // No Get.locale/translations in this app - force a full rebuild so
    // every inline bn/en ternary re-evaluates against the new language.
    Get.forceAppUpdate();
  }
}
