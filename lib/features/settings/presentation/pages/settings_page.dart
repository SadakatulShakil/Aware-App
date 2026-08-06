import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/services/theme_service.dart';
import '../../../../shared/widgets/bilingual_label.dart';

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
        title: BilingualLabel(
          bn: 'সেটিংস',
          en: 'Settings',
          activeColor: c.textPrimary,
          activeSize: 18,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 110.h),
        children: [
          _sectionCard(c, 'ভাষা', 'Language', [
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
          _sectionCard(c, 'থিম', 'Theme', [
            Obx(() => Column(
                  children: [ThemeMode.dark, ThemeMode.light]
                      .map((mode) => RadioListTile<ThemeMode>(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: BilingualLabel(
                              bn: _labelBn(mode),
                              en: _label(mode),
                              activeColor: c.textPrimary,
                              activeSize: 14,
                            ),
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
          _sectionCard(c, 'নোটিফিকেশন', 'Notifications', [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.notifications_active_outlined,
                  color: c.primary),
              title: Text('notification_settings'.tr,
                  style: AppTextStyles.body(c.textPrimary)),
              subtitle: Text('notification_settings_subtitle'.tr,
                  style: AppTextStyles.caption(c.textSecondary)),
              trailing: Icon(Icons.chevron_right, color: c.textSecondary),
              onTap: () => Get.toNamed(AppRoutes.notificationSettings),
            ),
          ]),
          SizedBox(height: 12.h),
          _sectionCard(c, 'অ্যাপ সম্পর্কে', 'About', [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.info_outline, color: c.primary),
              title: Text('AWARE v1.0.0',
                  style: AppTextStyles.body(c.textPrimary)),
              subtitle: BilingualLabel(
                bn: 'দুর্যোগ ব্যবস্থাপনা অধিদপ্তর (ডিডিএম), এমওডিএমআর',
                en: 'Department of Disaster Management (DDM), MoDMR',
                activeColor: c.textSecondary,
                activeSize: 12,
              ),
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

  String _labelBn(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'লাইট';
      case ThemeMode.dark:
        return 'ডার্ক';
      case ThemeMode.system:
        return 'সিস্টেম ডিফল্ট';
    }
  }

  Widget _sectionCard(AppThemeColors c, String titleBn, String titleEn, List<Widget> children) {
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
          BilingualLabel(
            bn: titleBn,
            en: titleEn,
            activeColor: c.textPrimary,
            activeSize: 15,
          ),
          SizedBox(height: 4.h),
          ...children,
        ],
      ),
    );
  }
}
