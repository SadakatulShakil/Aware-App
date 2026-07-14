import '../../../../core/database/app_database.dart';
import '../../../../core/utils/app_logger.dart';
import '../datasources/hazard_static_data.dart';
import '../models/hazard_entity.dart';

/// Offline-first hazard source.
/// Today: Floor DB seeded with static data.
/// Later:  fetch from ApiEndpoints.hazards -> upsert into Floor -> same read.
class HazardRepository {
  final AppDatabase? _db;

  HazardRepository(this._db);

  Future<List<HazardEntity>> getHazards() async {
    final db = _db;
    if (db == null) return HazardStaticData.seed();
    try {
      var list = await db.hazardDao.findAll();
      if (list.isEmpty) {
        await db.hazardDao.insertAll(HazardStaticData.seed());
        list = await db.hazardDao.findAll();
      }
      return list;
    } catch (e) {
      AppLogger.w('Hazard DB read failed, using static seed: $e');
      return HazardStaticData.seed();
    }
  }

  // TODO(API): Future<void> refreshFromApi() async {
  //   final json = await Get.find<ApiClient>().get(ApiEndpoints.hazards);
  //   final items = (json['data'] as List)
  //       .map((e) => HazardEntity.fromJson(e)).toList();
  //   await _db?.hazardDao.clearAll();
  //   await _db?.hazardDao.insertAll(items);
  // }
}
