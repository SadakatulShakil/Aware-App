import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../../core/constants/app_constants.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        title: Text('জরুরি সেবা / Emergency',
            style: AppTextStyles.sectionTitle(c.textPrimary)),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: c.emergency.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: c.emergency.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.sos, color: c.emergency, size: 32.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                      '২৪/৭ জরুরি হটলাইন সেবা\nবিপদে পড়লে নিচের নম্বরে কল করুন',
                      style: AppTextStyles.body(c.textPrimary)),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          ...AppConstants.hotlines.map((h) => Container(
                margin: EdgeInsets.only(bottom: 10.h),
                decoration: BoxDecoration(
                  color: c.cardBg,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: c.emergency.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child:
                        Icon(Icons.call, color: c.emergency, size: 20.sp),
                  ),
                  title: Text(h['titleBn']!,
                      style: AppTextStyles.title(c.textPrimary)),
                  subtitle: Text(h['title']!,
                      style: AppTextStyles.caption(c.textSecondary)),
                  trailing: Text(h['number']!,
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: c.emergency)),
                  onTap: () => _call(h['number']!),
                ),
              )),
        ],
      ),
    );
  }
}
