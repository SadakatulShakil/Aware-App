import 'package:floor/floor.dart';

@Entity(tableName: 'services')
class ServiceModel {
  @PrimaryKey()
  final String id;
  final String title;
  final String iconUrl;
  final String url;

  /// 'bn' | 'en' - the app language this row was fetched in. Used to
  /// detect a stale-language cache (see ServiceRepository).
  final String lang;

  final int updatedAt; // epoch millis

  ServiceModel({
    required this.id,
    required this.title,
    required this.iconUrl,
    required this.url,
    required this.lang,
    required this.updatedAt,
  });

  /// The API sends a literal backslash+n inside title text (e.g. the raw
  /// JSON "IVR\\nSystem" decodes to the Dart string "IVR\nSystem", which is
  /// the two characters '\' and 'n' - NOT a real newline). Convert that,
  /// plus <br>/<br/>/<br /> as a defensive fallback if the backend ever
  /// switches to HTML breaks, into real line breaks for display.
  String get displayTitle =>
      title.replaceAll(r'\n', '\n').replaceAll(RegExp(r'<br\s*/?>'), '\n').trim();

  /// Maps the DDM service/list response - the caller (ServiceRepository)
  /// supplies [lang] (titles here are technical/acronym names and come
  /// back the same regardless of language).
  factory ServiceModel.fromJson(Map<String, dynamic> json, {required String lang}) =>
      ServiceModel(
        id: json['id']?.toString() ?? '',
        title: json['title'] ?? '',
        iconUrl: json['icon'] ?? '',
        url: json['url'] ?? '',
        lang: lang,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'icon': iconUrl,
        'url': url,
        'lang': lang,
        'updatedAt': updatedAt,
      };
}
