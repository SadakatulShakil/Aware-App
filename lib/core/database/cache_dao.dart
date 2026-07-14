import 'package:floor/floor.dart';

import 'cache_entity.dart';

@dao
abstract class CacheDao {
  @Query('SELECT * FROM cache WHERE `key` = :key')
  Future<CacheEntity?> find(String key);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> upsert(CacheEntity entity);
}
