import 'package:get/get.dart';

import '../../features/emergency/presentation/pages/emergency_page.dart';
import '../../features/main_nav/presentation/bindings/main_nav_binding.dart';
import '../../features/main_nav/presentation/pages/main_nav_page.dart';
import '../../features/splash/presentation/bindings/splash_binding.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.mainNav,
      page: () => const MainNavPage(),
      binding: MainNavBinding(),
    ),
    GetPage(
      name: AppRoutes.emergency,
      page: () => const EmergencyPage(),
    ),
  ];
}
