import '../models/hazard_entity.dart';

/// Static seed matching rapid.ddm.gov.bd home cards.
/// When the API is ready: HazardRepository fetches -> upserts into Floor ->
/// UI does not change at all.
class HazardStaticData {
  HazardStaticData._();

  static List<HazardEntity> seed() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return [
      HazardEntity(
          hazardKey: 'flood',
          titleEn: 'Flood',
          titleBn: 'বন্যা',
          updatedAt: now),
      HazardEntity(
          hazardKey: 'cyclone',
          titleEn: 'Cyclone',
          titleBn: 'ঘূর্ণিঝড়',
          updatedAt: now),
      HazardEntity(
          hazardKey: 'lightning',
          titleEn: 'Lightning',
          titleBn: 'বজ্রপাত',
          updatedAt: now),
      HazardEntity(
          hazardKey: 'flash_flood',
          titleEn: 'Flash Flood',
          titleBn: 'আকস্মিক বন্যা',
          updatedAt: now),
      HazardEntity(
          hazardKey: 'landslide',
          titleEn: 'Landslide',
          titleBn: 'ভূমিধস',
          updatedAt: now),
      HazardEntity(
          hazardKey: 'earthquake',
          titleEn: 'Earthquake',
          titleBn: 'ভূমিকম্প',
          updatedAt: now),
    ];
  }
}
