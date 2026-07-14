import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/services/theme_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);
    final themeService = Get.find<ThemeService>();
    final languageService = Get.find<LanguageService>();

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        title: Text('সেটিংস / Settings',
            style: AppTextStyles.sectionTitle(c.textPrimary)),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 110.h),
        children: [
          _sectionCard(c, 'ভাষা / Language', [
            Obx(() => Column(
                  children: [
                    RadioListTile<String>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('বাংলা', style: AppTextStyles.body(c.textPrimary)),
                      value: 'bn',
                      groupValue: languageService.code.value,
                      activeColor: c.primary,
                      onChanged: (v) {
                        if (v != null) languageService.setLanguage(v);
                      },
                    ),
                    RadioListTile<String>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('English', style: AppTextStyles.body(c.textPrimary)),
                      value: 'en',
                      groupValue: languageService.code.value,
                      activeColor: c.primary,
                      onChanged: (v) {
                        if (v != null) languageService.setLanguage(v);
                      },
                    ),
                  ],
                )),
          ]),
          SizedBox(height: 12.h),
          _sectionCard(c, 'থিম / Theme', [
            Obx(() => Column(
                  children: ThemeMode.values
                      .map((mode) => RadioListTile<ThemeMode>(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(_label(mode),
                                style: AppTextStyles.body(c.textPrimary)),
                            value: mode,
                            groupValue: themeService.mode.value,
                            activeColor: c.primary,
                            onChanged: (m) {
                              if (m != null) themeService.setMode(m);
                            },
                          ))
                      .toList(),
                )),
          ]),
          SizedBox(height: 12.h),
          _sectionCard(c, 'নোটিফিকেশন / Notifications', [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.notifications_active_outlined,
                  color: c.primary),
              title: Text('Alert notifications',
                  style: AppTextStyles.body(c.textPrimary)),
              subtitle: Text('Managed from system settings',
                  style: AppTextStyles.caption(c.textSecondary)),
            ),
          ]),
          SizedBox(height: 12.h),
          _sectionCard(c, 'অ্যাপ সম্পর্কে / About', [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.info_outline, color: c.primary),
              title: Text('AWARE v1.0.0',
                  style: AppTextStyles.body(c.textPrimary)),
              subtitle: Text(
                  'Department of Disaster Management (DDM), MoDMR',
                  style: AppTextStyles.caption(c.textSecondary)),
            ),
          ]),
        ],
      ),
    );
  }

  String _label(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System default';
    }
  }

  Widget _sectionCard(AppThemeColors c, String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.title(c.textPrimary)),
          SizedBox(height: 4.h),
          ...children,
        ],
      ),
    );
  }
}
