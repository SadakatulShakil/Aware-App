import 'package:flutter/material.dart';

/// Maps a single entry of DDM's `/alerts` response - a live count card
/// (e.g. active cyclone warnings, flood alerts) with a server-supplied
/// background color, shown in the home page AlertsGrid.
class AlertItemModel {
  final String id;
  final String title;
  final String value;
  final Color color;

  const AlertItemModel({
    required this.id,
    required this.title,
    required this.value,
    required this.color,
  });

  factory AlertItemModel.fromJson(Map<String, dynamic> json) => AlertItemModel(
        id: json['id']?.toString() ?? '',
        title: json['title'] ?? '',
        value: json['value']?.toString() ?? '',
        color: _parseColor(json['color']),
      );

  static Color _parseColor(dynamic hex) {
    if (hex is! String || hex.isEmpty) return const Color(0xFF1B5E9E);
    var value = hex.replaceAll('#', '');
    if (value.length == 6) value = 'FF$value';
    final parsed = int.tryParse(value, radix: 16);
    return parsed != null ? Color(parsed) : const Color(0xFF1B5E9E);
  }

  static List<AlertItemModel> listFromJson(dynamic json) {
    if (json is! List) return [];
    return json
        .map((e) => AlertItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
