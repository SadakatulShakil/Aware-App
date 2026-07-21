import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../../core/constants/app_constants.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        title: Text('অ্যাপ সম্পর্কে / About', style: AppTextStyles.sectionTitle(c.textPrimary)),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.asset(AppConstants.logoPath, width: 72.r, height: 72.r),
                ),
                SizedBox(height: 10.h),
                Text('${AppConstants.appName} v${AppConstants.appVersion}',
                    style: AppTextStyles.heading(c.textPrimary)),
                SizedBox(height: 4.h),
                Text(AppConstants.appFullName,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption(c.textSecondary)),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          _card(
            c,
            titleBn: 'অ্যাপ সম্পর্কে',
            titleEn: 'About the App',
            child: Text(
              'AWARE আপনাকে বাস্তব সময়ে আবহাওয়ার পূর্বাভাস, দুর্যোগ সতর্কতা এবং জরুরি সেবার তথ্য প্রদান করে, '
              'যাতে আপনি এবং আপনার পরিবার প্রাকৃতিক দুর্যোগের ঝুঁকি মোকাবিলায় প্রস্তুত থাকতে পারেন।\n\n'
              'AWARE gives you real-time weather forecasts, disaster alerts, and emergency service '
              'information so you and your family stay prepared against natural hazards.',
              style: AppTextStyles.body(c.textPrimary),
            ),
          ),
          SizedBox(height: 12.h),
          _card(
            c,
            titleBn: 'পরিচালনায়',
            titleEn: 'Maintained By',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppConstants.orgName, style: AppTextStyles.body(c.textPrimary)),
                SizedBox(height: 4.h),
                Text('Ministry of Disaster Management and Relief (MoDMR), Bangladesh',
                    style: AppTextStyles.caption(c.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(AppThemeColors c,
      {required String titleBn, required String titleEn, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(color: c.cardBg, borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$titleBn / $titleEn', style: AppTextStyles.title(c.textPrimary)),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }
}
