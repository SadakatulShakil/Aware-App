import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/upazila_list_model.dart';

class LocationRepository {
  Future<List<UpazilaData>> getUpazilas() async {
    final raw = await rootBundle.loadString('assets/json/location_list.json');
    final decoded = jsonDecode(raw);
    final list = decoded is Map<String, dynamic>
        ? (decoded['data'] as List? ?? decoded['result'] as List? ?? [])
        : decoded as List;
    return list
        .map((e) => UpazilaData.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
