import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/theme_service.dart';
import '../../../../core/services/user_pref_service.dart';
import '../../../../core/utils/app_logger.dart';

/// Deferred bootstrap - runs AFTER the first frame is on screen,
/// keeping cold start fast (BMD Android Vitals lesson).
class SplashController extends GetxController {
  final RxString statusText = ''.obs;

  @override
  void onReady() {
    super.onReady();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // 1. Preferences (single SharedPreferences gateway)
    final prefs = await UserPrefService().init();
    Get.put<UserPrefService>(prefs, permanent: true);

    // 2. Saved theme + language
    Get.put<ThemeService>(ThemeService(), permanent: true).applySaved();
    Get.put<LanguageService>(LanguageService(), permanent: true).applySaved();

    // 3. Floor database (guarded - app must run even if codegen/db fails)
    try {
      final db = await $FloorAppDatabase.databaseBuilder('aware.db').build();
      Get.put<AppDatabase>(db, permanent: true);
    } catch (e) {
      AppLogger.e('Floor DB init failed', e);
    }

    // 4. Notification permission + channel + FCM (guarded)
    statusText.value = 'নোটিফিকেশন প্রস্তুত হচ্ছে...';
    await NotificationService.instance.init();

    // 5. Location permission - only block on this when there is no saved
    // location yet (first launch / fresh install). getLocation(isSilent:
    // false) shows the rationale/system dialogs; HomeController's silent
    // auto-sync (onReady) handles subsequent launches and falls back to
    // the manual picker if the user ends up denying here.
    if (prefs.lat == null || prefs.lat!.isEmpty) {
      statusText.value = 'অবস্থান প্রস্তুত হচ্ছে...';
      try {
        await LocationService.instance.getLocation(onSettingsOpened: () {});
      } catch (e) {
        AppLogger.e('Splash location resolve failed', e);
      }
    }

    if (prefs.isFirstLaunch) await prefs.setFirstLaunchDone();

    // 6. Enter the app
    Get.offAllNamed(AppRoutes.mainNav);
  }
}
