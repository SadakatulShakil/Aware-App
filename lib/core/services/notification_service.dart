import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../features/home/presentation/controllers/home_controller.dart';
import '../utils/app_logger.dart';
import 'notification_pref.dart';
import 'user_pref_service.dart';

/// MUST be top-level - runs in a separate isolate when the app is killed.
/// No BuildContext, no Get.to, no UI operations allowed here. Registered
/// with FirebaseMessaging.onBackgroundMessage BEFORE any other listener.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.d('BG FCM received: ${message.notification?.title}');
  // System shows the notification automatically from the FCM payload.
  // Only add a local show() here if the backend later sends data-only messages.
}

/// FCM + local notifications.
///
/// SERVER PAYLOAD RULES (learned on BMD):
/// - For background/killed delivery, do NOT put a `sound` field in the
///   FCM payload; the Android channel below owns the sound.
/// - Channel importance MAX so heads-up shows on Samsung One UI.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const _alertChannelId = 'aware_alerts';
  static const _alertChannelName = 'Disaster Alerts';
  static const _alertChannelDescription = 'Weather & disaster alerts from DDM';

  static const _generalChannelId = 'aware_general';
  static const _generalChannelName = 'General Notifications';
  static const _generalChannelDescription =
      'Weather updates and general information';

  final NotificationPrefs _prefs = NotificationPrefs();

  /// `'default'` means no custom sound (system default ringtone).
  AndroidNotificationSound? _soundFor(String ringtone) =>
      ringtone == 'default' ? null : RawResourceAndroidNotificationSound(ringtone);

  /// Android 8+ locks a channel's sound/vibration/audio-attributes at
  /// creation time, so these are rebuilt from the live prefs whenever the
  /// channel is (re)created.
  AndroidNotificationChannel _buildAlertChannel() => AndroidNotificationChannel(
        _alertChannelId,
        _alertChannelName,
        description: _alertChannelDescription,
        importance: Importance.max,
        playSound: true,
        sound: _soundFor(_prefs.alertRingtone),
        enableVibration: true,
        // Alarm stream bypasses silent/DND when emergency bypass is on.
        audioAttributesUsage: _prefs.emergencyBypass
            ? AudioAttributesUsage.alarm
            : AudioAttributesUsage.notification,
        showBadge: true,
      );

  AndroidNotificationChannel _buildGeneralChannel() =>
      AndroidNotificationChannel(
        _generalChannelId,
        _generalChannelName,
        description: _generalChannelDescription,
        importance: Importance.high,
        playSound: true,
        sound: _soundFor(_prefs.generalRingtone),
        enableVibration: _prefs.generalVibration,
        showBadge: true,
      );

  /// Stores the FCM message from a terminated-state tap. Consumed by
  /// handlePendingFcmNavigation(), called from HomeController.onReady().
  RemoteMessage? _pendingMessage;

  /// Guarded init - app must still run if google-services.json/Firebase
  /// project setup is incomplete.
  Future<void> init() async {
    try {
      const initSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      await _local.initialize(initSettings);

      final androidImpl = _local.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.createNotificationChannel(_buildAlertChannel());
      await androidImpl?.createNotificationChannel(_buildGeneralChannel());
      // Android 13+ runtime notification permission
      await androidImpl?.requestNotificationsPermission();
    } catch (e) {
      AppLogger.w('Local notifications init failed: $e');
    }

    try {
      await Firebase.initializeApp();

      // Register BEFORE any other Firebase listener.
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      if (Platform.isIOS) {
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      await messaging.subscribeToTopic('all_users');

      final token = await messaging.getToken();
      AppLogger.d('FCM token: $token');
      if (token != null) {
        // Persist only - HomeController's background refresh (2s after UI
        // is stable) is what actually sends it, once lat/lon are resolved.
        await Get.find<UserPrefService>().setFcmToken(token);
      }

      messaging.onTokenRefresh.listen((newToken) async {
        AppLogger.d('FCM token refreshed: $newToken');
        await Get.find<UserPrefService>().setFcmToken(newToken);
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().sendFcmTokenToServer();
        }
      });

      // App is open - FCM is silent on Android, must show locally.
      FirebaseMessaging.onMessage.listen(_showForeground);

      // App was minimised, user taps notification - navigator is ready.
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        AppLogger.d('FCM background tap: ${message.data}');
        _pendingMessage = message;
        handlePendingFcmNavigation();
      });

      // App was killed, launched by tapping the notification - navigator
      // is NOT ready yet. Store it; HomeController.onReady() consumes it.
      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        AppLogger.d('FCM terminated tap - stored for later');
        _pendingMessage = initial;
      }
    } catch (e) {
      // Expected until the Firebase project + google-services.json are
      // fully wired end to end.
      AppLogger.w('Firebase init skipped: $e');
    }
  }

  Future<void> _showForeground(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    final isAlert = message.data['type'] == 'alert';
    await showNotification(
      isAlert: isAlert,
      title: notification.title,
      body: notification.body,
    );
  }

  /// Shows a local notification on the appropriate channel, honoring the
  /// user's NotificationPrefs toggles.
  Future<void> showNotification({
    required bool isAlert,
    required String? title,
    required String? body,
  }) async {
    if (isAlert && !_prefs.alertsEnabled) return;
    if (!isAlert && !_prefs.generalEnabled) return;

    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      _detailsFor(isAlert),
    );
  }

  NotificationDetails _detailsFor(bool isAlert) {
    final sound =
        _soundFor(isAlert ? _prefs.alertRingtone : _prefs.generalRingtone);

    if (isAlert) {
      return NotificationDetails(
        android: AndroidNotificationDetails(
          _alertChannelId,
          _alertChannelName,
          channelDescription: _alertChannelDescription,
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          sound: sound,
          enableVibration: true,
          // Alarm stream + alarm category bypass silent/DND when the user
          // has emergency bypass enabled.
          audioAttributesUsage: _prefs.emergencyBypass
              ? AudioAttributesUsage.alarm
              : AudioAttributesUsage.notification,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: _prefs.fullScreenAlert,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: _prefs.emergencyBypass
              ? InterruptionLevel.critical
              : InterruptionLevel.active,
        ),
      );
    }

    return NotificationDetails(
      android: AndroidNotificationDetails(
        _generalChannelId,
        _generalChannelName,
        channelDescription: _generalChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        sound: sound,
        enableVibration: _prefs.generalVibration,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  /// Called from the notification settings page's Test buttons.
  Future<void> showTestNotification(bool isAlert) async {
    await showNotification(
      isAlert: isAlert,
      title: isAlert ? 'test_alert_title'.tr : 'test_general_title'.tr,
      body: isAlert ? 'test_alert_body'.tr : 'test_general_body'.tr,
    );
  }

  /// Android 8+ locks a channel's sound/vibration/audio-attributes at
  /// creation time - a preference change only takes effect once the
  /// channel is deleted and recreated from the live prefs.
  Future<void> updateAlertChannel() => _recreateChannel(
        id: _alertChannelId,
        build: _buildAlertChannel,
      );

  Future<void> updateGeneralChannel() => _recreateChannel(
        id: _generalChannelId,
        build: _buildGeneralChannel,
      );

  Future<void> _recreateChannel({
    required String id,
    required AndroidNotificationChannel Function() build,
  }) async {
    final androidImpl = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    try {
      await androidImpl?.deleteNotificationChannel(id);
      await androidImpl?.createNotificationChannel(build());
    } catch (e) {
      AppLogger.w('Recreating channel $id failed: $e');
    }
  }

  /// Called by HomeController.onReady() - safe to touch GetX navigation
  /// here. AWARE has no dedicated notification detail page, so a tap
  /// from a killed/background state just lands the user on the main
  /// screen (where alerts/hazards already live).
  void handlePendingFcmNavigation() {
    if (_pendingMessage == null) return;
    _pendingMessage = null;
    AppLogger.d('FCM pending nav consumed - landing on main screen');
    if (Get.currentRoute != AppRoutes.mainNav) {
      Get.offAllNamed(AppRoutes.mainNav);
    }
  }
}
