import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../utils/app_logger.dart';

/// FCM + local notifications.
///
/// SERVER PAYLOAD RULES (learned on BMD):
/// - For background/killed delivery, do NOT put a `sound` field in the
///   FCM payload; the Android channel below owns the sound.
/// - Use HTTP v1 API on the server side.
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
  );

  /// Guarded init - app must still run if google-services.json is not yet
  /// configured (Firebase project setup is a separate step).
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
      // Android 13+ runtime notification permission
      await androidImpl?.requestNotificationsPermission();
    } catch (e) {
      AppLogger.w('Local notifications init failed: $e');
    }

    try {
      await Firebase.initializeApp();
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
          alert: true, badge: true, sound: true);
      await messaging.subscribeToTopic('all_users');

      FirebaseMessaging.onMessage.listen(_showForeground);
      final token = await messaging.getToken();
      AppLogger.d('FCM token: $token');
    } catch (e) {
      // Expected until Firebase project + google-services.json are added.
      AppLogger.w('Firebase init skipped: $e');
    }
  }

  Future<void> _showForeground(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    await _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _alertChannel.id,
          _alertChannel.name,
          channelDescription: _alertChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}
