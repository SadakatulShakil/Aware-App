import 'dart:async';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/services/user_pref_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../datasources/service_static_data.dart';
import '../models/service_model.dart';

/// DDM service/list source, offline-first via Floor.
/// The response language is controlled globally by ApiClient - not set here.
class ServiceRepository {
  final AppDatabase? _db;
  final ApiClient _api;

  ServiceRepository(this._db, this._api);

  Future<List<ServiceModel>> getServices() async {
    final currentLang = Get.find<UserPrefService>().appLanguage;
    try {
      return await _fetchAndCache(currentLang);
    } catch (e) {
      AppLogger.w('Service fetch failed, falling back to cache: $e');
      return _fallbackFromCache(currentLang);
    }
  }

  Future<List<ServiceModel>> _fetchAndCache(String lang) async {
    final json = await _api.get(ApiEndpoints.serviceList);
    if (json['status'] != true) throw ApiException.parsing();

    final items = (json['result'] as List)
        .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>, lang: lang))
        .toList();

    final db = _db;
    if (db != null) {
      await db.serviceDao.clearAll();
      await db.serviceDao.insertAll(items);
    }

    _prefetchIcons(items);
    return items;
  }

  Future<List<ServiceModel>> _fallbackFromCache(String currentLang) async {
    final db = _db;
    if (db == null) return ServiceStaticData.seed(lang: currentLang);
    try {
      final cached = await db.serviceDao.findAll();
      if (cached.isEmpty) return ServiceStaticData.seed(lang: currentLang);

      if (cached.first.lang != currentLang) {
        // Wrong-language cache (e.g. language changed while offline) - show
        // it now rather than nothing, and opportunistically retry the live
        // fetch so Floor holds the right language as soon as network
        // returns (picked up by the next load()/UI refresh).
        unawaited(_fetchAndCache(currentLang).catchError((_) => <ServiceModel>[]));
      }
      return cached;
    } catch (e) {
      AppLogger.w('Service cache read failed, using static seed: $e');
      return ServiceStaticData.seed(lang: currentLang);
    }
  }

  /// Icons must still show with no internet - precache each to disk right
  /// after a successful fetch, fire-and-forget so it never blocks the grid.
  void _prefetchIcons(List<ServiceModel> items) {
    for (final item in items) {
      if (item.iconUrl.isEmpty) continue;
      unawaited(_prefetchIcon(item.iconUrl));
    }
  }

  Future<void> _prefetchIcon(String url) async {
    try {
      await DefaultCacheManager().downloadFile(url);
    } catch (e) {
      AppLogger.w('Service icon prefetch failed for $url: $e');
    }
  }
}
