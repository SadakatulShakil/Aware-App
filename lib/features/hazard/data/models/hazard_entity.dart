import 'package:floor/floor.dart';

@Entity(tableName: 'hazards')
class HazardEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  /// flood | cyclone | lightning | flash_flood | landslide | earthquake
  final String hazardKey;
  final String titleEn;
  final String titleBn;

  /// normal | moderate | heavy | extreme (null = no active alert)
  final String? severity;

  /// Short status/summary shown on card - will come from API later.
  final String? summary;

  final int updatedAt; // epoch millis

  HazardEntity({
    this.id,
    required this.hazardKey,
    required this.titleEn,
    required this.titleBn,
    this.severity,
    this.summary,
    required this.updatedAt,
  });

  /// For the future API integration - repository will map JSON -> entity
  /// and upsert into Floor, UI keeps reading the same table (offline-first).
  factory HazardEntity.fromJson(Map<String, dynamic> json) => HazardEntity(
        hazardKey: json['hazard_key'] ?? '',
        titleEn: json['title_en'] ?? '',
        titleBn: json['title_bn'] ?? '',
        severity: json['severity'],
        summary: json['summary'],
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
}
