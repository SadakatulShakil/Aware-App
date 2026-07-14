class WeatherForecastModel {
  bool? status;
  String? message;
  ForecastResult? result;

  WeatherForecastModel({this.status, this.message, this.result});

  WeatherForecastModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    result =
        json['result'] != null ? ForecastResult.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (result != null) {
      data['result'] = result!.toJson();
    }
    return data;
  }
}

class ForecastResult {
  Location? location;
  ForecastEntry? current;
  List<ForecastEntry>? daily;
  List<ForecastEntry>? steps;
  ChartData? dailyChart;
  ChartData? stepsChart;

  ForecastResult({
    this.location,
    this.current,
    this.daily,
    this.steps,
    this.dailyChart,
    this.stepsChart,
  });

  ForecastResult.fromJson(Map<String, dynamic> json) {
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;
    current =
        json['current'] != null ? ForecastEntry.fromJson(json['current']) : null;
    if (json['daily'] != null) {
      daily = <ForecastEntry>[];
      json['daily'].forEach((v) {
        daily!.add(ForecastEntry.fromJson(v));
      });
    }
    if (json['steps'] != null) {
      steps = <ForecastEntry>[];
      json['steps'].forEach((v) {
        steps!.add(ForecastEntry.fromJson(v));
      });
    }
    dailyChart = json['daily_chart'] != null
        ? ChartData.fromJson(json['daily_chart'])
        : null;
    stepsChart = json['steps_chart'] != null
        ? ChartData.fromJson(json['steps_chart'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (location != null) data['location'] = location!.toJson();
    if (current != null) data['current'] = current!.toJson();
    if (daily != null) data['daily'] = daily!.map((v) => v.toJson()).toList();
    if (steps != null) data['steps'] = steps!.map((v) => v.toJson()).toList();
    if (dailyChart != null) data['daily_chart'] = dailyChart!.toJson();
    if (stepsChart != null) data['steps_chart'] = stepsChart!.toJson();
    return data;
  }
}

class Location {
  String? id;
  String? division;
  String? district;
  String? upazila;
  String? divisionBn;
  String? districtBn;
  String? upazilaBn;
  String? forecastDate;
  String? updatedAt;
  String? locationName;

  Location({
    this.id,
    this.division,
    this.district,
    this.upazila,
    this.divisionBn,
    this.districtBn,
    this.upazilaBn,
    this.forecastDate,
    this.updatedAt,
    this.locationName,
  });

  Location.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    division = json['division'];
    district = json['district'];
    upazila = json['upazila'];
    divisionBn = json['division_bn'];
    districtBn = json['district_bn'];
    upazilaBn = json['upazila_bn'];
    forecastDate = json['forecast_date'];
    updatedAt = json['updated_at'];
    locationName = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['division'] = division;
    data['district'] = district;
    data['upazila'] = upazila;
    data['division_bn'] = divisionBn;
    data['district_bn'] = districtBn;
    data['upazila_bn'] = upazilaBn;
    data['forecast_date'] = forecastDate;
    data['updated_at'] = updatedAt;
    data['location'] = locationName;
    return data;
  }
}

class ForecastEntry {
  String? stepStart;
  String? stepEnd;
  String? date;
  String? weekday;
  String? rfUnit;
  String? tempUnit;
  String? icon;
  String? type;
  String? typen;
  NumericRange? rf;
  NumericRange? temp;
  String? feels;
  String? pressure;
  String? windspd;
  String? winddir;
  String? aqi;
  String? aqLevel;
  String? start;
  String? end;

  ForecastEntry({
    this.stepStart,
    this.stepEnd,
    this.date,
    this.weekday,
    this.rfUnit,
    this.tempUnit,
    this.icon,
    this.type,
    this.typen,
    this.rf,
    this.temp,
    this.feels,
    this.pressure,
    this.windspd,
    this.winddir,
    this.aqi,
    this.aqLevel,
    this.start,
    this.end,
  });

  ForecastEntry.fromJson(Map<String, dynamic> json) {
    stepStart = json['step_start'];
    stepEnd = json['step_end'];
    date = json['date'];
    weekday = json['weekday'];
    rfUnit = json['rf_unit'];
    tempUnit = json['temp_unit'];
    icon = json['icon'];
    type = json['type'];
    typen = json['typen'];
    rf = json['rf'] != null ? NumericRange.fromJson(json['rf']) : null;
    temp = json['temp'] != null ? NumericRange.fromJson(json['temp']) : null;
    feels = json['feels']?.toString();
    pressure = json['pressure']?.toString();
    windspd = json['windspd'] is Map
        ? NumericRange.fromJson(json['windspd']).valAvg
        : json['windspd']?.toString();
    winddir = json['winddir'] is Map
        ? NumericRange.fromJson(json['winddir']).valAvg
        : json['winddir']?.toString();
    aqi = json['aqi']?.toString();
    aqLevel = json['aqLevel']?.toString();
    start = json['start'];
    end = json['end'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['step_start'] = stepStart;
    data['step_end'] = stepEnd;
    data['date'] = date;
    data['weekday'] = weekday;
    data['rf_unit'] = rfUnit;
    data['temp_unit'] = tempUnit;
    data['icon'] = icon;
    data['type'] = type;
    data['typen'] = typen;
    if (rf != null) data['rf'] = rf!.toJson();
    if (temp != null) data['temp'] = temp!.toJson();
    data['feels'] = feels;
    data['pressure'] = pressure;
    data['windspd'] = windspd;
    data['winddir'] = winddir;
    data['aqi'] = aqi;
    data['aqLevel'] = aqLevel;
    data['start'] = start;
    data['end'] = end;
    return data;
  }
}

class NumericRange {
  String? valMin;
  String? valAvg;
  String? valMax;

  NumericRange({this.valMin, this.valAvg, this.valMax});

  NumericRange.fromJson(Map<String, dynamic> json) {
    valMin = json['val_min']?.toString();
    valAvg = json['val_avg']?.toString();
    valMax = json['val_max']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['val_min'] = valMin?.toString();
    data['val_avg'] = valAvg?.toString();
    data['val_max'] = valMax?.toString();
    return data;
  }
}

class ChartData {
  List<double>? tempValMin;
  List<double>? tempValMax;
  List<double>? rfValMax;
  List<double>? rhValAvg;
  List<double>? windValAvg;

  ChartData({
    this.tempValMin,
    this.tempValMax,
    this.rfValMax,
    this.rhValAvg,
    this.windValAvg,
  });

  ChartData.fromJson(Map<String, dynamic> json) {
    tempValMin = _parseList(json['temp_val_min']);
    tempValMax = _parseList(json['temp_val_max']);
    rfValMax = _parseList(json['rf_val_max']);
    rhValAvg = _parseList(json['rh_val_avg']);
    windValAvg = _parseList(json['wind_val_avg']);
  }

  List<double>? _parseList(dynamic list) {
    if (list == null) return null;
    if (list is List) {
      return list.map((e) => double.tryParse(e.toString()) ?? 0.0).toList();
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['temp_val_min'] = tempValMin?.map((e) => e.toString()).toList();
    data['temp_val_max'] = tempValMax?.map((e) => e.toString()).toList();
    data['rf_val_max'] = rfValMax?.map((e) => e.toString()).toList();
    data['rh_val_avg'] = rhValAvg?.map((e) => e.toString()).toList();
    data['wind_val_avg'] = windValAvg?.map((e) => e.toString()).toList();
    return data;
  }
}
