class AlertItemModel {
  final String id;
  final String title;
  final String value;
  final String type;

  const AlertItemModel({
    required this.id,
    required this.title,
    required this.value,
    required this.type,
  });

  factory AlertItemModel.fromJson(Map<String, dynamic> json) => AlertItemModel(
        id: json['id']?.toString() ?? '',
        title: json['title'] ?? '',
        value: json['value']?.toString() ?? '',
        type: json['type']?.toString() ?? '1',
      );

  static List<AlertItemModel> listFromJson(dynamic json) {
    if (json is! List) return [];
    return json
        .map((e) => AlertItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
