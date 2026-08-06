import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_theme_colors.dart';
import '../../../core/services/user_pref_service.dart';
import '../data/models/incident_report_model.dart';

class IncidentReportSuccessPage extends StatelessWidget {
  final IncidentReportModel report;

  const IncidentReportSuccessPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);
    final isBangla = Get.find<UserPrefService>().isBangla;

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96.w,
                height: 96.w,
                decoration: BoxDecoration(color: c.secondary.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(Icons.check_circle_outline, color: c.secondary, size: 56.sp),
              ),
              SizedBox(height: 24.h),
              Text(
                isBangla ? 'রিপোর্ট সফলভাবে জমা হয়েছে' : 'Incident Uploaded Successfully',
                textAlign: TextAlign.center,
                style: AppTextStyles.sectionTitle(c.textPrimary),
              ),
              SizedBox(height: 10.h),
              Text(
                isBangla
                    ? 'আপনার প্রতিবেদনের জন্য ধন্যবাদ। কর্তৃপক্ষ শীঘ্রই এটি পর্যালোচনা করবে।'
                    : 'Thank you for your report. The authorities will review it shortly.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body(c.textSecondary),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Get.toNamed(AppRoutes.myIncidentPosts, arguments: report.mobile),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text(isBangla ? 'আপনার পোস্ট দেখুন' : 'View Your Post',
                      style: AppTextStyles.title(c.textOnPrimary)),
                ),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () => Get.offAllNamed(AppRoutes.incidentReport),
                child: Text(
                  isBangla ? 'রিপোর্ট পাতায় ফিরে যান' : 'Back to Report Page',
                  style: AppTextStyles.title(c.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
