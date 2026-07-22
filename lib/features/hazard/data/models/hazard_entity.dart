import 'package:floor/floor.dart';

@Entity(tableName: 'hazards')
class HazardEntity {
  @PrimaryKey()
  final String id;
  final String title;
  final String iconUrl;
  final String url;

  /// 'bn' | 'en' - the app language this row was fetched in. Used to
  /// detect a stale-language cache (see HazardRepository).
  final String lang;

  final int updatedAt; // epoch millis

  HazardEntity({
    required this.id,
    required this.title,
    required this.iconUrl,
    required this.url,
    required this.lang,
    required this.updatedAt,
  });

  /// Maps the DDM hazard/list response - titles come back already
  /// localized for the requested language, so there is no local
  /// translation map here. The caller (HazardRepository) supplies [lang].
  factory HazardEntity.fromJson(Map<String, dynamic> json, {required String lang}) =>
      HazardEntity(
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
