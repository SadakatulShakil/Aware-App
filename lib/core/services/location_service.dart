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
    final isBangla = Get.find<UserPrefService>().isBangla;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _showServiceDisabledDialog(isBangla);
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return true;
    }

    if (permission == LocationPermission.deniedForever) {
      await _showPermanentlyDeniedDialog(isBangla);
      return false;
    }

    if (permission == LocationPermission.denied) {
      final shouldRequest = await _showRationaleDialog(isBangla);
      if (shouldRequest != true) return false;

      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        return true;
      }
      if (permission == LocationPermission.deniedForever) {
        await _showPermanentlyDeniedDialog(isBangla);
      }
      return false;
    }

    return false;
  }

  Future<Position?> _getCurrentLocation({
    required VoidCallback onSettingsOpened,
    bool isSilent = false,
  }) async {
    final isBangla = Get.find<UserPrefService>().isBangla;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!isSilent) await _showServiceDisabledDialog(isBangla);
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      if (!isSilent) await _showPermanentlyDeniedDialog(isBangla);
      return null;
    }

    if (permission == LocationPermission.denied) {
      if (isSilent) return null;

      final shouldRequest = await _showRationaleDialog(isBangla);
      if (shouldRequest != true) return null;

      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        if (permission == LocationPermission.deniedForever) {
          await _showPermanentlyDeniedDialog(isBangla);
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

  // ── Dialogs (Bangla + English, ported verbatim from BMD) ──

  Future<bool?> _showRationaleDialog(bool isBangla) async {
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
                isBangla ? 'অবস্থান অনুমতি' : 'Location Permission',
                style: AppFonts.style(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            isBangla
                ? 'আপনার সঠিক আবহাওয়ার তথ্য পেতে আমাদের আপনার বর্তমান অবস্থান জানা দরকার। অনুগ্রহ করে অবস্থান অনুমতি প্রদান করুন।'
                : 'We need your location to show accurate local weather forecasts for your area. Please allow location access.',
            style: AppFonts.style(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                isBangla ? 'এখন না' : 'Not Now',
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
                isBangla ? 'অনুমতি দিন' : 'Allow',
                style: AppFonts.style(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showServiceDisabledDialog(bool isBangla) async {
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
                isBangla ? 'লোকেশন বন্ধ' : 'Location Disabled',
                style: AppFonts.style(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            isBangla
                ? 'আপনার ডিভাইসের লোকেশন সার্ভিস বন্ধ আছে। সঠিক আবহাওয়া দেখতে লোকেশন চালু করুন।'
                : 'Your device location service is turned off. Please enable location to get accurate weather for your area.',
            style: AppFonts.style(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                isBangla ? 'পরে করব' : 'Later',
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
                isBangla ? 'সেটিংস খুলুন' : 'Open Settings',
                style: AppFonts.style(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showPermanentlyDeniedDialog(bool isBangla) async {
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
                isBangla ? 'অনুমতি প্রত্যাখ্যাত' : 'Permission Denied',
                style: AppFonts.style(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            isBangla
                ? 'লোকেশন অনুমতি স্থায়ীভাবে বন্ধ করা হয়েছে। সেটিংসে গিয়ে অবস্থান অনুমতি চালু করুন।'
                : 'Location permission has been permanently denied. Please go to app settings and enable location permission.',
            style: AppFonts.style(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                isBangla ? 'পরে করব' : 'Later',
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
                isBangla ? 'অ্যাপ সেটিংস' : 'App Settings',
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
