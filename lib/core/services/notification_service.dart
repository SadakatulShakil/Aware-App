import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../utils/app_logger.dart';
import 'notification_pref.dart';

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

  static const AndroidNotificationChannel _alertChannel =
      AndroidNotificationChannel(
    'aware_alerts',
    'Disaster Alerts',
    description: 'Weather & disaster alerts from DDM',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static const AndroidNotificationChannel _generalChannel =
      AndroidNotificationChannel(
    'aware_general',
    'General Notifications',
    description: 'Weather updates and general information',
    importance: Importance.high,
    playSound: true,
    enableVibration: false,
  );

  final NotificationPrefs _prefs = NotificationPrefs();

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
      await androidImpl?.createNotificationChannel(_alertChannel);
      await androidImpl?.createNotificationChannel(
        AndroidNotificationChannel(
          _generalChannel.id,
          _generalChannel.name,
          description: _generalChannel.description,
          importance: _generalChannel.importance,
          playSound: _generalChannel.playSound,
          enableVibration: _prefs.generalVibration,
        ),
      );
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
      // TODO(DDM API): POST token to the DDM backend once that endpoint
      // exists. Do NOT call BMD's /notification/token - that's their backend.

      messaging.onTokenRefresh.listen((newToken) {
        AppLogger.d('FCM token refreshed: $newToken');
        // TODO(DDM API): push the refreshed token once the endpoint exists.
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

    final channel = isAlert ? _alertChannel : _generalChannel;
    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: channel.importance,
          priority: isAlert ? Priority.max : Priority.high,
          icon: '@mipmap/ic_launcher',
          enableVibration: isAlert ? true : _prefs.generalVibration,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
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

  /// Android 8+ locks a channel's vibration setting at creation time - a
  /// preference toggle only takes effect if the channel is recreated.
  Future<void> updateGeneralChannelVibration(bool enabled) async {
    final androidImpl = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    try {
      await androidImpl?.deleteNotificationChannel(_generalChannel.id);
      await androidImpl?.createNotificationChannel(
        AndroidNotificationChannel(
          _generalChannel.id,
          _generalChannel.name,
          description: _generalChannel.description,
          importance: _generalChannel.importance,
          playSound: _generalChannel.playSound,
          enableVibration: enabled,
        ),
      );
    } catch (e) {
      AppLogger.w('updateGeneralChannelVibration failed: $e');
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
