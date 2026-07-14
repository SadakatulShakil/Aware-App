import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../app/theme/app_fonts.dart';
import '../constants/api_endpoints.dart';
import '../network/api_client.dart';
import '../../features/home/data/models/forecast_model.dart';
import 'user_pref_service.dart';

/// BMD-style location system, ported 1:1 (dialogs, thresholds, GPS-entry
/// bugfix). Routed through the single ApiClient instead of raw http,
/// per AWARE's "one HTTP gateway" rule.
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<bool> isPermissionGranted() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Main entry point - handles all permission states with proper UX dialogs.
  /// [isSilent] = true -> no dialogs, just try silently (background sync).
  /// [isSilent] = false -> show rationale/settings dialogs (user-triggered).
  Future<bool> getLocation({
    required VoidCallback onSettingsOpened,
    int timeoutSeconds = 10,
    bool isSilent = false,
  }) async {
    final prefs = Get.find<UserPrefService>();
    try {
      final position = await _getCurrentLocation(
        onSettingsOpened: onSettingsOpened,
        isSilent: isSilent,
      );
      if (position == null) return false;

      final api = Get.find<ApiClient>();
      final lang = prefs.appLanguage;
      final json = await api.get(
        ApiEndpoints.bmdForecast,
        query: {
          'type': 'point',
          'lat': '${position.latitude}',
          'lon': '${position.longitude}',
        },
        headers: {'Accept-Language': lang},
      ).timeout(Duration(seconds: timeoutSeconds));

      final forecast = WeatherForecastModel.fromJson(json);
      final loc = forecast.result?.location;

      if (isSilent || !prefs.isFollowingGPS) {
        // Background sync OR user has a custom location selected:
        // update only the GPS list entry - never overwrite LAT/LON
        // when a custom location is active.
        await prefs.updateGPSLocationSilently(
          position.latitude.toStringAsFixed(5),
          position.longitude.toStringAsFixed(5),
          loc?.id ?? '',
          loc?.locationName ?? '',
          loc?.upazila ?? '',
          loc?.upazilaBn ?? '',
          loc?.district ?? '',
          loc?.districtBn ?? '',
          loc?.division ?? '',
          loc?.divisionBn ?? '',
        );
      } else {
        // User is actively following GPS - update everything.
        await prefs.saveLocationData(
          position.latitude.toStringAsFixed(5),
          position.longitude.toStringAsFixed(5),
          loc?.id ?? '',
          loc?.locationName ?? '',
          loc?.upazila ?? '',
          loc?.upazilaBn ?? '',
          loc?.district ?? '',
          loc?.districtBn ?? '',
          loc?.division ?? '',
          loc?.divisionBn ?? '',
        );
      }
      return true;
    } catch (e) {
      if (prefs.isFollowingGPS) {
        // API/parsing failed but we still have a fresh GPS fix - keep
        // LAT/LON current so the next forecast call at least has coords.
        try {
          final position = await Geolocator.getLastKnownPosition();
          if (position != null) {
            await prefs.saveLatLonData(
              position.latitude.toStringAsFixed(5),
              position.longitude.toStringAsFixed(5),
            );
          }
        } catch (_) {}
      }
      return false;
    }
  }

  /// Returns true if permission was granted after the request.
  Future<bool> requestPermissionWithRationale() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _showServiceDisabledDialog();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return true;
    }

    if (permission == LocationPermission.deniedForever) {
      await _showPermanentlyDeniedDialog();
      return false;
    }

    if (permission == LocationPermission.denied) {
      final shouldRequest = await _showRationaleDialog();
      if (shouldRequest != true) return false;

      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        return true;
      }
      if (permission == LocationPermission.deniedForever) {
        await _showPermanentlyDeniedDialog();
      }
      return false;
    }

    return false;
  }

  Future<Position?> _getCurrentLocation({
    required VoidCallback onSettingsOpened,
    bool isSilent = false,
  }) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!isSilent) await _showServiceDisabledDialog();
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      if (!isSilent) await _showPermanentlyDeniedDialog();
      return null;
    }

    if (permission == LocationPermission.denied) {
      if (isSilent) return null;

      final shouldRequest = await _showRationaleDialog();
      if (shouldRequest != true) return null;

      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        if (permission == LocationPermission.deniedForever) {
          await _showPermanentlyDeniedDialog();
        }
        return null;
      }
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('GPS Timeout'),
      );
    } catch (_) {
      return null;
    }
  }

  // ── Dialogs (bn/en via .tr, ported verbatim from BMD) ──

  Future<bool?> _showRationaleDialog() async {
    return await Get.dialog<bool>(
      PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue.shade700, size: 28),
              const SizedBox(width: 8),
              Text(
                'loc_permission_title'.tr,
                style: AppFonts.style(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'loc_permission_body'.tr,
            style: AppFonts.style(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                'not_now'.tr,
                style: AppFonts.style(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Get.back(result: true),
              child: Text(
                'allow'.tr,
                style: AppFonts.style(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showServiceDisabledDialog() async {
    await Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.location_off, color: Colors.orange.shade700, size: 28),
              const SizedBox(width: 8),
              Text(
                'location_disabled_title'.tr,
                style: AppFonts.style(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'location_disabled_body'.tr,
            style: AppFonts.style(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'later'.tr,
                style: AppFonts.style(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Get.back();
                await Geolocator.openLocationSettings();
              },
              child: Text(
                'open_settings'.tr,
                style: AppFonts.style(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showPermanentlyDeniedDialog() async {
    await Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.location_disabled, color: Colors.red.shade700, size: 28),
              const SizedBox(width: 8),
              Text(
                'permission_denied_title'.tr,
                style: AppFonts.style(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'permission_denied_body'.tr,
            style: AppFonts.style(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'later'.tr,
                style: AppFonts.style(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Get.back();
                await Geolocator.openAppSettings();
              },
              child: Text(
                'app_settings'.tr,
                style: AppFonts.style(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}
