import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void d(Object? msg) {
    if (kDebugMode) debugPrint('[AWARE] $msg');
  }

  static void w(Object? msg) {
    if (kDebugMode) debugPrint('[AWARE][WARN] $msg');
  }

  static void e(Object? msg, [Object? error, StackTrace? st]) {
    if (kDebugMode) {
      debugPrint('[AWARE][ERROR] $msg ${error ?? ''}');
      if (st != null) debugPrint(st.toString());
    }
  }
}
