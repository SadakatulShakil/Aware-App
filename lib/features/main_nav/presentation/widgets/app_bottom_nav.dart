import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_theme_colors.dart';
import '../controllers/main_nav_controller.dart';

class AppBottomNav extends GetView<MainNavController> {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);
    return BottomAppBar(
      color: c.navBarBg,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      padding: EdgeInsets.zero,
      height: 64.h,
      child: Obx(
        () => Row(
          children: [
            _item(c, 0, Icons.home_outlined, Icons.home, 'nav_home'),
            _item(c, 1, Icons.warning_amber_outlined, Icons.warning_amber, 'nav_hazard'),
            SizedBox(width: 72.w), // notch space for Emergency FAB
            _item(c, 2, Icons.grid_view_outlined, Icons.grid_view, 'nav_services'),
            _item(c, 3, Icons.settings_outlined, Icons.settings, 'nav_settings'),
          ],
        ),
      ),
    );
  }

  Widget _item(AppThemeColors c, int index, IconData icon, IconData activeIcon,
      String labelKey) {
    final selected = controller.currentIndex.value == index;
    return Expanded(
      child: InkWell(
        onTap: () => controller.changeTab(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : icon,
                size: selected ? 24.sp : 20.sp,
                color: selected ? c.primary : c.textSecondary),
            SizedBox(height: 2.h),
            Text(labelKey.tr,
                style: TextStyle(
                    fontSize: selected ? 15.sp : 12.sp,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? c.primary : c.textSecondary)),
          ],
        ),
      ),
    );
  }
}
