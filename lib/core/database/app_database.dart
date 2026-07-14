import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../../features/hazard/data/datasources/hazard_dao.dart';
import '../../features/hazard/data/models/hazard_entity.dart';
import 'cache_dao.dart';
import 'cache_entity.dart';

part 'app_database.g.dart';

/// Run once after pub get:
///   dart run build_runner build --delete-conflicting-outputs
@Database(version: 2, entities: [HazardEntity, CacheEntity])
abstract class AppDatabase extends FloorDatabase {
  HazardDao get hazardDao;
  CacheDao get cacheDao;
}
