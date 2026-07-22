import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../../features/hazard/data/datasources/hazard_dao.dart';
import '../../features/hazard/data/models/hazard_entity.dart';
import '../../features/services/data/datasources/service_dao.dart';
import '../../features/services/data/models/service_model.dart';
import 'cache_dao.dart';
import 'cache_entity.dart';

part 'app_database.g.dart';

/// v2 -> v3: the `hazards` table moved from the old static shape
/// (hazardKey/titleEn/titleBn/severity/summary) to the DDM hazard/list API
/// shape (id/title/iconUrl/url/lang). Floor (unlike Room) has no
/// fallbackToDestructiveMigration() helper, so this migration reproduces
/// that behavior by hand - it's just an offline cache, re-seeded on the
/// next successful fetch, so a destructive drop+recreate is safe.
final hazardsMigrationV2ToV3 = Migration(2, 3, (database) async {
  await database.execute('DROP TABLE IF EXISTS `hazards`');
  await database.execute(
      'CREATE TABLE IF NOT EXISTS `hazards` (`id` TEXT NOT NULL, `title` TEXT NOT NULL, `iconUrl` TEXT NOT NULL, `url` TEXT NOT NULL, `lang` TEXT NOT NULL, `updatedAt` INTEGER NOT NULL, PRIMARY KEY (`id`))');
});

/// v3 -> v4: adds the `services` table (DDM service/list API - same
/// id/title/iconUrl/url/lang shape as hazards). New table, nothing to
/// migrate away from, so just create it.
final servicesMigrationV3ToV4 = Migration(3, 4, (database) async {
  await database.execute(
      'CREATE TABLE IF NOT EXISTS `services` (`id` TEXT NOT NULL, `title` TEXT NOT NULL, `iconUrl` TEXT NOT NULL, `url` TEXT NOT NULL, `lang` TEXT NOT NULL, `updatedAt` INTEGER NOT NULL, PRIMARY KEY (`id`))');
});

/// Run once after pub get:
///   dart run build_runner build --delete-conflicting-outputs
@Database(version: 4, entities: [HazardEntity, CacheEntity, ServiceModel])
abstract class AppDatabase extends FloorDatabase {
  HazardDao get hazardDao;
  CacheDao get cacheDao;
  ServiceDao get serviceDao;
}
