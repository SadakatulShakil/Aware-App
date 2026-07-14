import 'package:get/get.dart';

import 'user_pref_service.dart';

/// User-controllable notification toggles, ported from BMD's NotificationPrefs
/// (scoped to what AWARE's NotificationService actually implements - no
/// ringtone picker / full-screen-intent / DND-bypass, since those aren't
/// wired up yet and a toggle that does nothing would be misleading).
class NotificationPrefs {
  static const _alertsEnabledKey = 'notif_alerts_enabled';
  static const _generalEnabledKey = 'notif_general_enabled';
  static const _generalVibrationKey = 'notif_general_vibration';

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
}
