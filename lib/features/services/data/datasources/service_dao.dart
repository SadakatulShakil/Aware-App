import 'package:floor/floor.dart';

import '../models/service_model.dart';

@dao
abstract class ServiceDao {
  @Query('SELECT * FROM services ORDER BY id ASC')
  Future<List<ServiceModel>> findAll();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAll(List<ServiceModel> services);

  @Query('DELETE FROM services')
  Future<void> clearAll();
}
