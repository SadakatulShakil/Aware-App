class UpazilaData {
  String? name;
  String? nameBn;
  String? pcode;
  dynamic lat;
  dynamic lng;
  String? district;
  String? districtBn;
  String? districtCode;
  String? division;
  String? divisionCode;

  UpazilaData({
    this.name,
    this.nameBn,
    this.pcode,
    this.lat,
    this.lng,
    this.district,
    this.districtBn,
    this.districtCode,
    this.division,
    this.divisionCode,
  });

  UpazilaData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    nameBn = json['name_bn'];
    pcode = json['pcode'];
    lat = json['lat'];
    lng = json['lng'];
    district = json['district'];
    districtBn = json['district_bn'];
    districtCode = json['district_code'];
    division = json['division'];
    divisionCode = json['division_code'];
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'name_bn': nameBn,
        'pcode': pcode,
        'lat': lat,
        'lng': lng,
        'district': district,
        'district_bn': districtBn,
        'district_code': districtCode,
        'division': division,
        'division_code': divisionCode,
      };
}
