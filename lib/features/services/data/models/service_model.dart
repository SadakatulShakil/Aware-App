import 'package:floor/floor.dart';

import '../../../../core/utils/lang_text.dart';

/// Local fallback titles keyed by the DDM service id - only used by
/// [ServiceModel.localizedTitle] when the API's title language doesn't
/// match what was requested (see lang_text.dart).
const Map<String, LangPair> serviceTitleFallback = {
  '1': (bn: 'আইভিআর সিস্টেম', en: 'IVR System'),
  '2': (bn: 'ডিএমসি পোর্টাল', en: 'DMC Portal'),
  '3': (bn: 'কিওস্ক ডিসপ্লে', en: 'KIOSK Display'),
  '4': (bn: 'আশ্রয়কেন্দ্র তথ্য', en: 'Shelter Information'),
  '5': (bn: 'সড়ক তথ্য', en: 'Road Information'),
  '6': (bn: 'ভিএমএস পোর্টাল', en: 'VMS Portal'),
  '7': (bn: 'ইসিআরএ ইউআরএ', en: 'eCRA eURA'),
  '8': (bn: 'বজ্রপাত তথ্য', en: 'Lightning Information'),
};

@Entity(tableName: 'services')
class ServiceModel {
  @PrimaryKey()
  final String id;
  final String title;
  final String iconUrl;
  final String url;
  final int updatedAt; // epoch millis

  ServiceModel({
    required this.id,
    required this.title,
    required this.iconUrl,
    required this.url,
    required this.updatedAt,
  });

  /// Resolves the title to show for [currentLang] - trusts the (cached) API
  /// title when its script matches the requested language, otherwise falls
  /// back to [serviceTitleFallback]. Computed at display time, not cached.
  String localizedTitle(String currentLang) {
    final fallback = serviceTitleFallback[id];
    if (fallback == null) {
      warnMissingTitleFallback('service', id, title, currentLang);
    }
    return resolveTitle(
      apiTitle: title,
      currentLang: currentLang,
      mapBn: fallback?.bn,
      mapEn: fallback?.en,
    );
  }

  /// The API sends a literal backslash+n inside title text (e.g. the raw
  /// JSON "IVR\\nSystem" decodes to the Dart string "IVR\nSystem", which is
  /// the two characters '\' and 'n' - NOT a real newline). Convert that,
  /// plus <br>/<br/>/<br /> as a defensive fallback if the backend ever
  /// switches to HTML breaks, into real line breaks for display - applied to
  /// the resolved (not raw) title from [localizedTitle].
  String displayTitle(String currentLang) => localizedTitle(currentLang)
      .replaceAll(r'\n', '\n')
      .replaceAll(RegExp(r'<br\s*/?>'), '\n')
      .trim();

  /// Maps the DDM service/list response - titles here are technical/acronym
  /// names and come back the same regardless of the requested language.
  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
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
}
