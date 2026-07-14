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

  /// Static placeholders mirroring the live DDM emergency bulletin.
  static List<AlertModel> mockList() => [
        AlertModel(
          id: '1',
          title: 'ভারী বৃষ্টিপাতের সতর্কবার্তা',
          message:
              'আগামী ২৪ ঘণ্টায় দেশের উত্তর-পূর্বাঞ্চলে ভারী থেকে অতি ভারী বর্ষণের সম্ভাবনা রয়েছে।',
          severity: 'heavy',
          updatedAt: DateTime.now(),
        ),
        AlertModel(
          id: '2',
          title: 'বন্যা সতর্কবার্তা',
          message:
              'সুরমা নদীর ছাতক ও কুশিয়ারা নদীর ফেঞ্চুগঞ্জ স্টেশনে পানি বিপদসীমার উপর দিয়ে প্রবাহিত হচ্ছে।',
          severity: 'extreme',
          updatedAt: DateTime.now(),
        ),
        AlertModel(
          id: '3',
          title: 'নৌ সতর্কবার্তা',
          message:
              'অভ্যন্তরীণ নদীবন্দরসমূহকে ১ নম্বর সতর্ক সংকেত দেখিয়ে যেতে বলা হয়েছে।',
          severity: 'moderate',
          updatedAt: DateTime.now(),
        ),
      ];
}
