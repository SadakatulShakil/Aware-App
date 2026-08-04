import 'package:floor/floor.dart';

import '../../../../core/utils/lang_text.dart';

/// Local fallback titles keyed by the DDM hazard id - only used by
/// [OngoingHazardEntity.localizedTitle] when the API's title language doesn't
/// match what was requested (see lang_text.dart).
const Map<String, LangPair> ongoingHazardTitleFallback = {
  '1': (bn: 'ঘূর্ণিঝড়', en: 'Cyclone'),
  '2': (bn: 'মৌসুমী বন্যা', en: 'Monsoon Flood'),
  '3': (bn: 'আকস্মিক বন্যা', en: 'Flash Flood'),
  '4': (bn: 'বজ্রপাত', en: 'Lightning'),
  '5': (bn: 'খরা', en: 'Drought'),
  '6': (bn: 'ভূমিধস', en: 'Landslide'),
  '7': (bn: 'ভূমিকম্প', en: 'Earthquakes'),
};

@Entity(tableName: 'ongoing_hazards')
class OngoingHazardEntity {
  @PrimaryKey()
  final String id;
  final String title;
  final String iconUrl;
  final String url;
  final int updatedAt; // epoch millis

  OngoingHazardEntity({
    required this.id,
    required this.title,
    required this.iconUrl,
    required this.url,
    required this.updatedAt,
  });

  /// Maps the DDM hazard/list response - titles come back already
  /// localized for the requested language (set via the Accept-Language
  /// header in ApiClient), so there is no local translation map here.
  factory OngoingHazardEntity.fromJson(Map<String, dynamic> json) => OngoingHazardEntity(
    id: json['id']?.toString() ?? '',
    title: json['title'] ?? '',
    iconUrl: json['icon'] ?? '',
    url: json['url'] ?? '',
    updatedAt: DateTime.now().millisecondsSinceEpoch,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'icon': iconUrl,
    'url': url,
    'updatedAt': updatedAt,
  };

  /// Resolves the title to show for [currentLang] - trusts the (cached) API
  /// title when its script matches the requested language, otherwise falls
  /// back to [ongoingHazardTitleFallback]. Computed at display time, not cached.
  String localizedTitle(String currentLang) {
    final fallback = ongoingHazardTitleFallback[id];
    if (fallback == null) {
      warnMissingTitleFallback('ongoing_hazard', id, title, currentLang);
    }
    return resolveTitle(
      apiTitle: title,
      currentLang: currentLang,
      mapBn: fallback?.bn,
      mapEn: fallback?.en,
    );
  }
}
