/// Maps DDM's `/alert/ongoing` response - a plain array of active bulletins,
/// each carrying its own PDF/report `link` to open on tap.
class OngoingBulletinModel {
  final String title;
  final String message;
  final String link;
  final DateTime lastUpdate;

  const OngoingBulletinModel({
    required this.title,
    required this.message,
    required this.link,
    required this.lastUpdate,
  });

  factory OngoingBulletinModel.fromJson(Map<String, dynamic> json) => OngoingBulletinModel(
        title: json['title'] ?? '',
        message: json['message'] ?? '',
        link: json['link'] ?? '',
        lastUpdate: DateTime.tryParse(json['lastupdate'] ?? '') ?? DateTime.now(),
      );

  static List<OngoingBulletinModel> listFromJson(dynamic json) {
    if (json is! List) return [];
    return json
        .map((e) => OngoingBulletinModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
