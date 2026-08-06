import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/user_pref_service.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _email(String address) async {
    final uri = Uri(scheme: 'mailto', path: address);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openWebsite(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);
    final isBangla = Get.find<UserPrefService>().isBangla;

    final tiles = [
      (
        Icons.call_outlined,
        'ফোন',
        'Phone',
        AppConstants.hotlines.last['number']!,
        () => _call(AppConstants.hotlines.last['number']!),
      ),
      (
        Icons.email_outlined,
        'ইমেইল',
        'Email',
        AppConstants.supportEmail,
        () => _email(AppConstants.supportEmail),
      ),
      (
        Icons.language_outlined,
        'ওয়েবসাইট',
        'Website',
        AppConstants.website,
        () => _openWebsite(AppConstants.website),
      ),
      (
        Icons.location_on_outlined,
        'ঠিকানা',
        'Address',
        AppConstants.officeAddress,
        null,
      ),
    ];

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        title: Text(isBangla ? 'যোগাযোগ করুন' : 'Contact Us',
            style: AppTextStyles.sectionTitle(c.textPrimary)),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Text(isBangla ? AppConstants.orgNameBn : AppConstants.orgName,
              style: AppTextStyles.title(c.textPrimary)),
          SizedBox(height: 16.h),
          ...tiles.map((t) => Container(
                margin: EdgeInsets.only(bottom: 10.h),
                decoration: BoxDecoration(color: c.cardBg, borderRadius: BorderRadius.circular(16.r)),
                child: ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration:
                        BoxDecoration(color: c.primary.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(t.$1, color: c.primary, size: 20.sp),
                  ),
                  title: Text(isBangla ? t.$2 : t.$3, style: AppTextStyles.caption(c.textSecondary)),
                  subtitle: Text(t.$4, style: AppTextStyles.body(c.textPrimary)),
                  trailing: t.$5 != null ? Icon(Icons.chevron_right, color: c.textSecondary) : null,
                  onTap: t.$5,
                ),
              )),
        ],
      ),
    );
  }
}
