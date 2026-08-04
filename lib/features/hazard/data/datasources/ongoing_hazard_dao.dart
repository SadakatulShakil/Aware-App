import 'package:floor/floor.dart';

import '../models/ongoing_hazard_entity.dart';


@dao
abstract class OngoingHazardDao {
  @Query('SELECT * FROM ongoing_hazards ORDER BY id ASC')
  Future<List<OngoingHazardEntity>> findAll();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAll(List<OngoingHazardEntity> hazards);

  @Query('DELETE FROM ongoing_hazards')
  Future<void> clearAll();
}
