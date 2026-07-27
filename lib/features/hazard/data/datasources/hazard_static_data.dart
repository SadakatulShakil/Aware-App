import '../models/hazard_entity.dart';

/// First-open fallback, shown only until the first successful
/// GET /hazard/list fetch replaces it in Floor.
///
/// NOTE: only 6 of the API's 7 hazard categories are represented here, and
/// iconUrl/url are left empty (grid falls back to a warning icon; tapping
/// is guarded against an empty url). The task only supplied one truncated
/// sample row (Cyclone, icon URL cut off with "...") - not the full 7-item
/// dump, so real icon/webview URLs were not fabricated here. Provide the
/// full JSON if you want the offline fallback to carry real artwork/links.
class HazardStaticData {
  HazardStaticData._();

  static List<HazardEntity> seed({String lang = 'bn'}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final isBangla = lang == 'bn';
    T pick<T>(T bn, T en) => isBangla ? bn : en;

    HazardEntity item(String id, String titleBn, String titleEn) => HazardEntity(
          id: id,
          title: pick(titleBn, titleEn),
          iconUrl: '',
          url: '',
          updatedAt: now,
        );

    return [
      item('1', 'ঘূর্ণিঝড়', 'Cyclone'),
      item('2', 'বন্যা', 'Flood'),
      item('3', 'বজ্রপাত', 'Lightning'),
      item('4', 'আকস্মিক বন্যা', 'Flash Flood'),
      item('5', 'ভূমিধস', 'Landslide'),
      item('6', 'ভূমিকম্প', 'Earthquake'),
    ];
  }
}
