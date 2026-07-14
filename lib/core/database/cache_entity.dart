import 'package:floor/floor.dart';

/// Generic string-keyed JSON cache (e.g. 'forecast_23.81_90.41').
@Entity(tableName: 'cache')
class CacheEntity {
  @PrimaryKey()
  final String key;

  final String jsonData;
  final int timestamp; // epoch millis

  CacheEntity({
    required this.key,
    required this.jsonData,
    required this.timestamp,
  });
}
