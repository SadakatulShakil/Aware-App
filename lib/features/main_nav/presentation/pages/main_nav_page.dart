import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../hazard/presentation/pages/hazard_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../services/presentation/pages/services_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../controllers/main_nav_controller.dart';
import '../widgets/app_bottom_nav.dart';

class MainNavPage extends GetView<MainNavController> {
  const MainNavPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);
    return Scaffold(
      extendBody: true,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            HomePage(),
            HazardPage(),
            ServicesPage(),
            SettingsPage(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 62.w,
        height: 62.w,
        child: FloatingActionButton(
          onPressed: () => Get.toNamed(AppRoutes.emergency),
          backgroundColor: c.emergency,
          shape: const CircleBorder(),
          child: Icon(Icons.sos, color: Colors.white, size: 28.sp),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}
