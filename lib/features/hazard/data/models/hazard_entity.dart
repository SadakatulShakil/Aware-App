import 'package:floor/floor.dart';

@Entity(tableName: 'hazards')
class HazardEntity {
  @PrimaryKey()
  final String id;
  final String title;
  final String iconUrl;
  final String url;
  final int updatedAt; // epoch millis

  HazardEntity({
    required this.id,
    required this.title,
    required this.iconUrl,
    required this.url,
    required this.updatedAt,
  });

  /// Maps the DDM hazard/list response - titles come back already
  /// localized for the requested language (set via the Accept-Language
  /// header in ApiClient), so there is no local translation map here.
  factory HazardEntity.fromJson(Map<String, dynamic> json) => HazardEntity(
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
