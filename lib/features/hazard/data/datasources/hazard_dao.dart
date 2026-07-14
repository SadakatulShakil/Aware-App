import 'package:floor/floor.dart';

import '../models/hazard_entity.dart';

@dao
abstract class HazardDao {
  @Query('SELECT * FROM hazards ORDER BY id ASC')
  Future<List<HazardEntity>> findAll();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAll(List<HazardEntity> hazards);

  @Query('DELETE FROM hazards')
  Future<void> clearAll();
}
