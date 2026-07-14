import 'dart:convert';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/cache_entity.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/forecast_model.dart';
import '../models/notification_model.dart';

/// Floor-backed cache for forecast ('forecast_${lat}_${lon}') and
/// notifications ('notifications_cache', matching BMD's cache key).
/// Null-safe if the DB failed to open (same pattern as HazardRepository).
class WeatherLocalRepository {
  final AppDatabase? _db;

  static const _notificationsKey = 'notifications_cache';

  WeatherLocalRepository(this._db);

  String _key(String lat, String lon) => 'forecast_${lat}_$lon';

  Future<WeatherForecastModel?> getCachedForecast(String lat, String lon) async {
    final db = _db;
    if (db == null || lat.isEmpty || lon.isEmpty) return null;
    try {
      final row = await db.cacheDao.find(_key(lat, lon));
      if (row == null) return null;
      return WeatherForecastModel.fromJson(
          jsonDecode(row.jsonData) as Map<String, dynamic>);
    } catch (e) {
      AppLogger.w('Forecast cache read failed: $e');
      return null;
    }
  }

  Future<void> cacheForecast(
      String lat, String lon, WeatherForecastModel model) async {
    final db = _db;
    if (db == null || lat.isEmpty || lon.isEmpty) return;
    try {
      await db.cacheDao.upsert(CacheEntity(
        key: _key(lat, lon),
        jsonData: jsonEncode(model.toJson()),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    } catch (e) {
      AppLogger.w('Forecast cache write failed: $e');
    }
  }

  Future<List<NotificationModel>?> getCachedNotifications() async {
    final db = _db;
    if (db == null) return null;
    try {
      final row = await db.cacheDao.find(_notificationsKey);
      if (row == null) return null;
      final list = jsonDecode(row.jsonData) as List;
      return list
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.w('Notifications cache read failed: $e');
      return null;
    }
  }

  Future<void> cacheNotifications(List<NotificationModel> notifications) async {
    final db = _db;
    if (db == null) return;
    try {
      await db.cacheDao.upsert(CacheEntity(
        key: _notificationsKey,
        jsonData: jsonEncode(notifications.map((n) => n.toJson()).toList()),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    } catch (e) {
      AppLogger.w('Notifications cache write failed: $e');
    }
  }
}
