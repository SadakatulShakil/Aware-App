import 'package:get/get.dart';

import 'user_pref_service.dart';

/// User-controllable notification toggles, ported from BMD's NotificationPrefs.
class NotificationPrefs {
  static const _alertsEnabledKey = 'notif_alerts_enabled';
  static const _generalEnabledKey = 'notif_general_enabled';
  static const _generalVibrationKey = 'notif_general_vibration';
  static const _fullScreenAlertKey = 'notif_fullscreen_alert';
  static const _emergencyBypassKey = 'notif_emergency_bypass';
  static const _alertRingtoneKey = 'notif_alert_ringtone';
  static const _generalRingtoneKey = 'notif_general_ringtone';

  UserPrefService get _prefs => Get.find<UserPrefService>();

  bool get alertsEnabled => _prefs.getBool(_alertsEnabledKey) ?? true;
  Future<void> setAlertsEnabled(bool v) => _prefs.setBool(_alertsEnabledKey, v);

  bool get generalEnabled => _prefs.getBool(_generalEnabledKey) ?? true;
  Future<void> setGeneralEnabled(bool v) => _prefs.setBool(_generalEnabledKey, v);

  // Alert notifications always vibrate (matches BMD's locked switch) - no
  // setter, this is intentionally read-only.
  bool get alertVibration => true;

  bool get generalVibration => _prefs.getBool(_generalVibrationKey) ?? false;
  Future<void> setGeneralVibration(bool v) => _prefs.setBool(_generalVibrationKey, v);

  // Full screen intent for alerts (shows on lock screen).
  bool get fullScreenAlert => _prefs.getBool(_fullScreenAlertKey) ?? true;
  Future<void> setFullScreenAlert(bool v) => _prefs.setBool(_fullScreenAlertKey, v);

  // Emergency bypass: uses the alarm audio stream so alerts sound even in
  // silent/DND mode - matches BMD.
  bool get emergencyBypass => _prefs.getBool(_emergencyBypassKey) ?? true;
  Future<void> setEmergencyBypass(bool v) => _prefs.setBool(_emergencyBypassKey, v);

  // Alert ringtone - defaults to the bundled custom tone.
  String get alertRingtone => _prefs.getString(_alertRingtoneKey) ?? 'notification_alert';
  Future<void> setAlertRingtone(String v) => _prefs.setString(_alertRingtoneKey, v);

  // General ringtone - defaults to the system default.
  String get generalRingtone => _prefs.getString(_generalRingtoneKey) ?? 'default';
  Future<void> setGeneralRingtone(String v) => _prefs.setString(_generalRingtoneKey, v);
}
