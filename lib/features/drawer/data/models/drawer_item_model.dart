import 'package:flutter/material.dart';

class DrawerItem {
  final IconData icon;
  final String labelKey;
  final String route;
  final Map<String, dynamic>? arguments;

  const DrawerItem(this.icon, this.labelKey, this.route, {this.arguments});
}