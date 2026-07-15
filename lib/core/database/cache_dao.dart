import 'package:floor/floor.dart';

import 'cache_entity.dart';

@dao
abstract class CacheDao {
  @Query('SELECT * FROM cache WHERE `key` = :key')
  Future<CacheEntity?> find(String key);

  /// Last-known forecast regardless of which coords it was cached under -
  /// fallback for when the exact-key lookup misses (see
  /// WeatherLocalRepository.getLatestCachedForecast).
  @Query("SELECT * FROM cache WHERE `key` LIKE 'forecast_%' ORDER BY timestamp DESC LIMIT 1")
  Future<CacheEntity?> getLatestForecastCache();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> upsert(CacheEntity entity);
}
