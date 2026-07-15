import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../controllers/splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c.headerGradientStart, c.headerGradientEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              // Replace with Image.asset(AssetPaths.logo) when logo is added
              Container(
                width: 96.w,
                height: 96.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Center(
                  child: Image.asset(AppConstants.logoPath, width: 64.w, height: 64.w),
                )
              ),
              SizedBox(height: 20.h),
              Text(AppConstants.appName,
                  style: TextStyle(
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                      color: Colors.white)),
              SizedBox(height: 6.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(AppConstants.appFullName,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption(Colors.white70)),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: 22.w,
                height: 22.w,
                child: const CircularProgressIndicator(
                    strokeWidth: 2.4, color: Colors.white),
              ),
              SizedBox(height: 12.h),
              Obx(() => Text(controller.statusText.value,
                  style: AppTextStyles.caption(Colors.white70))),
              SizedBox(height: 28.h),
              Text(AppConstants.orgName,
                  style: AppTextStyles.caption(Colors.white60)),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
