import 'dart:io';

import 'package:flutter/foundation.dart';

/// Ported 1:1 from BMD's device_service.dart - used to tag the FCM token
/// upload with the platform the backend expects ("android" | "ios" | "web" | "unknown").
Future<Map<String, dynamic>> getDeviceInfo() async {
  if (kIsWeb) return {'device': 'web'};
  if (Platform.isAndroid) return {'device': 'android'};
  if (Platform.isIOS) return {'device': 'ios'};
  return {'device': 'unknown'};
}
