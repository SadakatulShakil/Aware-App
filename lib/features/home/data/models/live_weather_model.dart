class LiveWeatherModel {
  final String type;
  final String videoUrl;
  final bool lightning;
  final String rainfall;
  final String temp;
  final String feelsLike;
  final String icon;

  const LiveWeatherModel({
    required this.type,
    required this.videoUrl,
    required this.lightning,
    required this.rainfall,
    required this.temp,
    required this.feelsLike,
    required this.icon,
  });

  factory LiveWeatherModel.fromJson(Map<String, dynamic> json) {
    return LiveWeatherModel(
      type: json['type']?.toString() ?? '',
      videoUrl: json['video']?.toString() ?? '',
      lightning: json['lightning'] == true,
      rainfall: json['rf']?.toString() ?? '',
      temp: json['temp']?.toString() ?? '',
      feelsLike: json['feels']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
    );
  }

  factory LiveWeatherModel.empty() => const LiveWeatherModel(
        type: '',
        videoUrl: '',
        lightning: false,
        rainfall: '',
        temp: '',
        feelsLike: '',
        icon: '',
      );
}
