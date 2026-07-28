import 'dart:async';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/services/user_pref_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../datasources/hazard_static_data.dart';
import '../models/hazard_entity.dart';

/// DDM hazard/list source, offline-first via Floor.
/// The response language is controlled globally by ApiClient - not set here.
class HazardRepository {
  final AppDatabase? _db;
  final ApiClient _api;

  HazardRepository(this._db, this._api);

  Future<List<HazardEntity>> getHazards() async {
    final currentLang = Get.find<UserPrefService>().appLanguage;
    try {
      return await _fetchAndCache(currentLang);
    } catch (e) {
      AppLogger.w('Hazard fetch failed, falling back to cache: $e');
      return _fallbackFromCache(currentLang);
    }
  }

  Future<List<HazardEntity>> _fetchAndCache(String currentLang) async {
    final json = await _api.get(ApiEndpoints.hazardList);
    if (json['status'] != true) throw ApiException.parsing();

    final items = (json['result'] as List)
        .map((e) => HazardEntity.fromJson(e as Map<String, dynamic>))
        .toList();

    final db = _db;
    if (db != null) {
      await db.hazardDao.clearAll();
      await db.hazardDao.insertAll(items);
    }

    _prefetchIcons(items);
    return items;
  }

  Future<List<HazardEntity>> _fallbackFromCache(String currentLang) async {
    final db = _db;
    if (db == null) return HazardStaticData.seed(lang: currentLang);
    try {
      final cached = await db.hazardDao.findAll();
      if (cached.isEmpty) return HazardStaticData.seed(lang: currentLang);
      return cached;
    } catch (e) {
      AppLogger.w('Hazard cache read failed, using static seed: $e');
      return HazardStaticData.seed(lang: currentLang);
    }
  }

  /// Icons must still show with no internet - precache each to disk right
  /// after a successful fetch, fire-and-forget so it never blocks the grid.
  void _prefetchIcons(List<HazardEntity> items) {
    for (final item in items) {
      if (item.iconUrl.isEmpty) continue;
      unawaited(_prefetchIcon(item.iconUrl));
    }
  }

  Future<void> _prefetchIcon(String url) async {
    try {
      await DefaultCacheManager().downloadFile(url);
    } catch (e) {
      AppLogger.w('Hazard icon prefetch failed for $url: $e');
    }
  }
}
