class AlertModel {
  final String id;
  final String title;
  final String message;
  final String severity; // normal | moderate | heavy | extreme
  final DateTime updatedAt;

  const AlertModel({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.updatedAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) => AlertModel(
        id: '${json['id'] ?? ''}',
        title: json['title'] ?? '',
        message: json['message'] ?? '',
        severity: json['severity'] ?? 'normal',
        updatedAt:
            DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'severity': severity,
        'updated_at': updatedAt.toIso8601String(),
      };
}
