import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../../core/services/notification_pref.dart';
import '../../../../core/services/notification_service.dart';

/// Notification preferences - ported 1:1 from BMD's NotificationSettingsPage
/// (alert/general master switches, per-channel ringtone selector, full-screen
/// alert toggle, emergency sound bypass), themed with AWARE's colors/text
/// styles and .tr localization instead of BMD's AppColors/AppFonts/_t().
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
  late bool _fullScreenAlert;
  late bool _emergencyBypass;
  late String _alertRingtone;
  late String _generalRingtone;

  Map<String, String> get _alertRingtones => {
        'notification_alert': 'ringtone_alert_tone'.tr,
        'default': 'ringtone_system_default'.tr,
      };

  Map<String, String> get _generalRingtones => {
        'default': 'ringtone_system_default'.tr,
        'notification_alert': 'ringtone_alert_tone'.tr,
      };

  @override
  void initState() {
    super.initState();
    _alertsEnabled = _prefs.alertsEnabled;
    _generalEnabled = _prefs.generalEnabled;
    _generalVibration = _prefs.generalVibration;
    _fullScreenAlert = _prefs.fullScreenAlert;
    _emergencyBypass = _prefs.emergencyBypass;
    _alertRingtone = _prefs.alertRingtone;
    _generalRingtone = _prefs.generalRingtone;
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
              _ringtoneSelector(
                c: c,
                options: _alertRingtones,
                selected: _alertRingtone,
                onSelect: (key) async {
                  setState(() => _alertRingtone = key);
                  await _prefs.setAlertRingtone(key);
                  await NotificationService.instance.updateAlertChannel();
                },
              ),
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
                      color: Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
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
          if (_alertsEnabled) ...[
            SizedBox(height: 12.h),
            _sectionCard(c, null, [
              _tile(
                c: c,
                icon: Icons.fullscreen,
                iconColor: Colors.deepPurple,
                title: 'full_screen_alert'.tr,
                subtitle: 'full_screen_alert_desc'.tr,
                value: _fullScreenAlert,
                onChanged: (v) async {
                  setState(() => _fullScreenAlert = v);
                  await _prefs.setFullScreenAlert(v);
                },
              ),
              const Divider(height: 16),
              _tile(
                c: c,
                icon: Icons.do_not_disturb_off_outlined,
                iconColor: Colors.red.shade600,
                title: 'emergency_bypass'.tr,
                subtitle: 'emergency_bypass_desc'.tr,
                value: _emergencyBypass,
                onChanged: (v) async {
                  setState(() => _emergencyBypass = v);
                  await _prefs.setEmergencyBypass(v);
                  await NotificationService.instance.updateAlertChannel();
                },
              ),
            ]),
            SizedBox(height: 8.h),
            _infoBanner(
              c: c,
              icon: _emergencyBypass ? Icons.info_outline : Icons.volume_off_outlined,
              color: _emergencyBypass ? Colors.orange : c.textSecondary,
              message: _emergencyBypass
                  ? 'emergency_bypass_on_info'.tr
                  : 'emergency_bypass_off_info'.tr,
            ),
          ],
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
              _ringtoneSelector(
                c: c,
                options: _generalRingtones,
                selected: _generalRingtone,
                onSelect: (key) async {
                  setState(() => _generalRingtone = key);
                  await _prefs.setGeneralRingtone(key);
                  await NotificationService.instance.updateGeneralChannel();
                },
              ),
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
                  await NotificationService.instance.updateGeneralChannel();
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

  Widget _ringtoneSelector({
    required AppThemeColors c,
    required Map<String, String> options,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.music_note_outlined, size: 16.sp, color: c.textSecondary),
            SizedBox(width: 6.w),
            Text('ringtone'.tr, style: AppTextStyles.caption(c.textSecondary)),
          ],
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 8.h,
          children: options.entries.map((entry) {
            final isSelected = selected == entry.key;
            return GestureDetector(
              onTap: () => onSelect(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? c.primary.withValues(alpha: 0.12)
                      : c.divider.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? c.primary : c.divider,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      Icon(Icons.check_circle, size: 14.sp, color: c.primary),
                      SizedBox(width: 4.w),
                    ],
                    Text(
                      entry.value,
                      style: (isSelected
                              ? AppTextStyles.body(c.primary)
                              : AppTextStyles.caption(c.textSecondary))
                          .copyWith(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _infoBanner({
    required AppThemeColors c,
    required IconData icon,
    required Color color,
    required String message,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(message, style: AppTextStyles.caption(color).copyWith(height: 1.5)),
          ),
        ],
      ),
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

  Widget _sectionCard(AppThemeColors c, String? title, List<Widget> children) {
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
          if (title != null) ...[
            Text(title, style: AppTextStyles.title(c.textPrimary)),
            SizedBox(height: 8.h),
          ],
          ...children,
        ],
      ),
    );
  }
}
