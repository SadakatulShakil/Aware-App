class SavedLocation {
  final String lat;
  final String lon;
  final String id;
  final String apiName; // name returned from API (real name)
  final String displayName; // user-facing name (Bangla)
  final String displayNameEn; // user-facing name (English)
  final String upazila;
  final String upazilaBn;
  final String district;
  final String districtBn;
  final String division;
  final String divisionBn;
  final bool isCurrent;
  final String createdAt;

  SavedLocation({
    required this.lat,
    required this.lon,
    required this.id,
    required this.apiName,
    required this.displayName,
    required this.displayNameEn,
    required this.upazila,
    required this.upazilaBn,
    required this.district,
    required this.districtBn,
    required this.division,
    required this.divisionBn,
    required this.isCurrent,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lon': lon,
        'id': id,
        'apiName': apiName,
        'displayName': displayName,
        'displayNameEn': displayNameEn,
        'upazila': upazila,
        'upazilaBn': upazilaBn,
        'district': district,
        'districtBn': districtBn,
        'division': division,
        'divisionBn': divisionBn,
        'isCurrent': isCurrent,
        'createdAt': createdAt,
      };

  factory SavedLocation.fromJson(Map<String, dynamic> json) => SavedLocation(
        lat: json['lat'] ?? '',
        lon: json['lon'] ?? '',
        id: json['id']?.toString() ?? '',
        apiName: json['apiName'] ?? '',
        displayName: json['displayName'] ?? '',
        displayNameEn: json['displayNameEn'] ?? '',
        upazila: json['upazila'] ?? '',
        upazilaBn: json['upazilaBn'] ?? '',
        district: json['district'] ?? '',
        districtBn: json['districtBn'] ?? '',
        division: json['division'] ?? '',
        divisionBn: json['divisionBn'] ?? '',
        isCurrent: json['isCurrent'] == true,
        createdAt: json['createdAt'] ?? '',
      );

  SavedLocation copyWith({
    String? lat,
    String? lon,
    String? id,
    String? apiName,
    String? displayName,
    String? displayNameEn,
    String? upazila,
    String? upazilaBn,
    String? district,
    String? districtBn,
    String? division,
    String? divisionBn,
    bool? isCurrent,
    String? createdAt,
  }) {
    return SavedLocation(
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      id: id ?? this.id,
      apiName: apiName ?? this.apiName,
      displayName: displayName ?? this.displayName,
      displayNameEn: displayNameEn ?? this.displayNameEn,
      upazila: upazila ?? this.upazila,
      upazilaBn: upazilaBn ?? this.upazilaBn,
      district: district ?? this.district,
      districtBn: districtBn ?? this.districtBn,
      division: division ?? this.division,
      divisionBn: divisionBn ?? this.divisionBn,
      isCurrent: isCurrent ?? this.isCurrent,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
