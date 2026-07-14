import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../../core/services/notification_pref.dart';
import '../../../../core/services/notification_service.dart';

/// Notification preferences - ported from BMD's NotificationSettingsPage,
/// scoped to what AWARE's NotificationService actually implements
/// (alert/general master switches + general vibration; no ringtone picker
/// or full-screen/DND-bypass since those aren't wired up).
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final _prefs = NotificationPrefs();

  late bool _alertsEnabled;
  late bool _generalEnabled;
  late bool _generalVibration;

  @override
  void initState() {
    super.initState();
    _alertsEnabled = _prefs.alertsEnabled;
    _generalEnabled = _prefs.generalEnabled;
    _generalVibration = _prefs.generalVibration;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        title: Text('notification_settings'.tr,
            style: AppTextStyles.sectionTitle(c.textPrimary)),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
        children: [
          _sectionCard(c, 'alert_notifications'.tr, [
            _tile(
              c: c,
              icon: Icons.warning_amber_rounded,
              iconColor: Colors.orange,
              title: 'alert_notifications'.tr,
              subtitle: 'alert_notifications_desc'.tr,
              value: _alertsEnabled,
              onChanged: (v) async {
                setState(() => _alertsEnabled = v);
                await _prefs.setAlertsEnabled(v);
              },
            ),
            if (_alertsEnabled) ...[
              const Divider(height: 16),
              Row(
                children: [
                  Icon(Icons.vibration, color: c.textSecondary, size: 20.sp),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('vibration'.tr, style: AppTextStyles.body(c.textSecondary)),
                        Text('vibration_locked_desc'.tr,
                            style: AppTextStyles.caption(c.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: Colors.orange.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline, size: 11.sp, color: Colors.orange.shade700),
                        SizedBox(width: 3.w),
                        Text('locked'.tr,
                            style: TextStyle(fontSize: 10.sp, color: Colors.orange.shade700)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ]),
          SizedBox(height: 12.h),
          _sectionCard(c, 'general_notifications'.tr, [
            _tile(
              c: c,
              icon: Icons.notifications_outlined,
              iconColor: c.primary,
              title: 'general_notifications'.tr,
              subtitle: 'general_notifications_desc'.tr,
              value: _generalEnabled,
              onChanged: (v) async {
                setState(() => _generalEnabled = v);
                await _prefs.setGeneralEnabled(v);
              },
            ),
            if (_generalEnabled) ...[
              const Divider(height: 16),
              _tile(
                c: c,
                icon: Icons.vibration,
                iconColor: c.primary,
                title: 'vibration'.tr,
                subtitle: 'vibration_general_desc'.tr,
                value: _generalVibration,
                onChanged: (v) async {
                  setState(() => _generalVibration = v);
                  await _prefs.setGeneralVibration(v);
                  await NotificationService.instance.updateGeneralChannelVibration(v);
                },
              ),
            ],
          ]),
          SizedBox(height: 20.h),
          Text('test'.tr, style: AppTextStyles.title(c.textPrimary)),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _testButton(
                  c: c,
                  label: 'test_general'.tr,
                  icon: Icons.notifications_outlined,
                  color: c.primary,
                  onTap: () async {
                    await NotificationService.instance.showTestNotification(false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('test_general_sent'.tr)),
                      );
                    }
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _testButton(
                  c: c,
                  label: 'test_alert'.tr,
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange,
                  onTap: () async {
                    await NotificationService.instance.showTestNotification(true);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('test_alert_sent'.tr)),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required AppThemeColors c,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20.sp),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.body(c.textPrimary)),
              Text(subtitle, style: AppTextStyles.caption(c.textSecondary)),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged, activeColor: c.primary),
      ],
    );
  }

  Widget _testButton({
    required AppThemeColors c,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: c.cardBg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: c.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22.sp),
            SizedBox(height: 6.h),
            Text(label,
                style: AppTextStyles.body(color).copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
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
          SizedBox(height: 8.h),
          ...children,
        ],
      ),
    );
  }
}
