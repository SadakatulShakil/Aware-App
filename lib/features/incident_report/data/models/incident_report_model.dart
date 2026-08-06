class IncidentReportModel {
  final String? id;
  final String name;
  final String mobile;
  final String hazardType; // always the English hazard key title, e.g. "Flood"
  final String location;
  final int deathCount;
  final int injuredCount;
  final int structuralDamage;
  final String imageBase64;
  final String description;
  final String lat;
  final String lon;
  final String deviceId;
  final DateTime? createdAt;

  const IncidentReportModel({
    this.id,
    required this.name,
    required this.mobile,
    required this.hazardType,
    required this.location,
    required this.deathCount,
    required this.injuredCount,
    required this.structuralDamage,
    required this.imageBase64,
    required this.description,
    required this.lat,
    required this.lon,
    required this.deviceId,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'mobile': mobile,
        'hazard_type': hazardType,
        'location': location,
        'death_count': deathCount,
        'injured_count': injuredCount,
        'structural_damage': structuralDamage,
        'image_base64': imageBase64,
        'description': description,
        'lat': lat,
        'lon': lon,
        'deviceid': deviceId,
      };

  factory IncidentReportModel.fromJson(Map<String, dynamic> json) {
    return IncidentReportModel(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      hazardType: json['hazard_type']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      deathCount: int.tryParse(json['death_count']?.toString() ?? '') ?? 0,
      injuredCount: int.tryParse(json['injured_count']?.toString() ?? '') ?? 0,
      structuralDamage:
          int.tryParse(json['structural_damage']?.toString() ?? '') ?? 0,
      imageBase64: json['image_base64']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      lat: json['lat']?.toString() ?? '',
      lon: json['lon']?.toString() ?? '',
      deviceId: json['deviceid']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
