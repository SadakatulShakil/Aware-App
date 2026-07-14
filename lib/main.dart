import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'core/services/localization_string.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // COLD START RULE (BMD Vitals lesson):
  // Nothing heavy before runApp(). No Firebase, no DB open, no prefs read here.
  // All heavy init is deferred to SplashController AFTER the first frame.
  runApp(const AwareApp());
}

class AwareApp extends StatelessWidget {
  const AwareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => GetMaterialApp(
        title: 'AWARE',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system, // saved mode re-applied in Splash
        translations: LocalizationString(),
        locale: const Locale('bn'), // saved language re-applied in Splash
        fallbackLocale: const Locale('bn'),
        initialBinding: InitialBinding(),
        initialRoute: AppRoutes.splash,
        getPages: AppPages.pages,
        defaultTransition: Transition.cupertino,
      ),
    );
  }
}
