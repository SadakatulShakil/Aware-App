import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/home/data/models/saved_location_model.dart';

/// SINGLE gateway to SharedPreferences.
/// RULE (BMD GPS-corruption lesson): no other class may create its own
/// SharedPreferences instance or write these keys directly - especially
/// background tasks / widgets. All reads & writes go through this service.
class UserPrefService {
  late final SharedPreferences _prefs;

  // ---- Keys (private - never leak outside this class) ----
  static const _kThemeMode = 'theme_mode';
  static const _kIsFirstLaunch = 'is_first_launch';
  static const _kAppLanguage = 'APP_LANGUAGE';

  // Location keys - ported verbatim from BMD (names matter: BMD's
  // saveLocationData/updateGPSLocationSilently were built around these).
  static const _kLat = 'LAT';
  static const _kLon = 'LON';
  static const _kLocationId = 'LOCATION_ID';
  static const _kLocationName = 'LOCATION_NAME';
  static const _kDisplayName = 'DISPLAY_NAME';
  static const _kLocationUpazila = 'LOCATION_UPAZILA';
  static const _kLocationUpazilaBn = 'LOCATION_UPAZILA_BN';
  static const _kLocationDistrict = 'LOCATION_DISTRICT';
  static const _kLocationDistrictBn = 'LOCATION_DISTRICT_BN';
  static const _kLocationDivision = 'LOCATION_DIVISION';
  static const _kLocationDivisionBn = 'LOCATION_DIVISION_BN';
  static const _kFollowGPS = 'FOLLOW_GPS';
  static const _kSavedLocations = 'SAVED_LOCATIONS';
  static const _kLiveVideoUrl = 'live_video_url';
  static const _kLiveWeatherType = 'live_weather_type';

  Future<UserPrefService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // ---- Theme ----
  String get themeMode => _prefs.getString(_kThemeMode) ?? 'system';
  Future<void> setThemeMode(String mode) => _prefs.setString(_kThemeMode, mode);

  // ---- First launch ----
  bool get isFirstLaunch => _prefs.getBool(_kIsFirstLaunch) ?? true;
  Future<void> setFirstLaunchDone() => _prefs.setBool(_kIsFirstLaunch, false);

  // ---- Generic bool flags (used by NotificationPrefs etc - still routed
  // through this single gateway, never a raw SharedPreferences instance) ----
  bool? getBool(String key) => _prefs.getBool(key);
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  // ---- App language ----
  String get appLanguage => _prefs.getString(_kAppLanguage) ?? 'bn';
  bool get isBangla => appLanguage == 'bn';
  Future<void> setAppLanguage(String code) =>
      _prefs.setString(_kAppLanguage, code);

  // ===== Location =====

  String? get lat => _prefs.getString(_kLat);
  String? get lon => _prefs.getString(_kLon);
  String? get locationId => _prefs.getString(_kLocationId);
  String? get locationName => _prefs.getString(_kLocationName);
  String? get displayName => _prefs.getString(_kDisplayName);
  String? get locationUpazila => _prefs.getString(_kLocationUpazila);
  String? get locationUpazilaBn => _prefs.getString(_kLocationUpazilaBn);
  String? get locationDistrict => _prefs.getString(_kLocationDistrict);
  String? get locationDistrictBn => _prefs.getString(_kLocationDistrictBn);
  String? get locationDivision => _prefs.getString(_kLocationDivision);
  String? get locationDivisionBn => _prefs.getString(_kLocationDivisionBn);
  bool get isFollowingGPS => _prefs.getBool(_kFollowGPS) ?? true;

  Future<void> setFollowGPS(bool follow) => _prefs.setBool(_kFollowGPS, follow);

  Future<void> saveLatLonData(String lat, String lon) async {
    await _prefs.setString(_kLat, lat);
    await _prefs.setString(_kLon, lon);
  }

  /// GPS mode only - writes the active location keys AND upserts the
  /// 'auto_gps' entry into the saved-locations list as current.
  Future<void> saveLocationData(
    String lat,
    String lon,
    String locationId,
    String locationName,
    String locationUpazila,
    String locationUpazilaBn,
    String locationDistrict,
    String locationDistrictBn,
    String locationDivision,
    String locationDivisionBn,
  ) async {
    await _prefs.setString(_kLat, lat);
    await _prefs.setString(_kLon, lon);
    await _prefs.setString(_kLocationId, locationId);
    await _prefs.setString(_kLocationName, locationName);
    await _prefs.setString(_kLocationUpazila, locationUpazila);
    await _prefs.setString(_kLocationUpazilaBn, locationUpazilaBn);
    await _prefs.setString(_kLocationDistrict, locationDistrict);
    await _prefs.setString(_kLocationDistrictBn, locationDistrictBn);
    await _prefs.setString(_kLocationDivision, locationDivision);
    await _prefs.setString(_kLocationDivisionBn, locationDivisionBn);

    final now = DateTime.now().toIso8601String();
    final sl = SavedLocation(
      lat: lat,
      lon: lon,
      id: 'auto_gps',
      apiName: locationName,
      displayName: "বর্তমান অবস্থান",
      displayNameEn: "Current Location",
      upazila: locationUpazila,
      upazilaBn: locationUpazilaBn,
      district: locationDistrict,
      districtBn: locationDistrictBn,
      division: locationDivision,
      divisionBn: locationDivisionBn,
      isCurrent: true,
      createdAt: now,
    );
    await _addOrUpdateSavedLocation(sl);
  }

  /// Updates only the 'auto_gps' list entry. Writes active LAT/LON keys
  /// ONLY when that entry is already the current one (or nothing is
  /// current yet) - never overwrites an active custom location.
  Future<void> updateGPSLocationSilently(
    String lat,
    String lon,
    String id,
    String name,
    String upazila,
    String upazilaBn,
    String district,
    String districtBn,
    String division,
    String divisionBn,
  ) async {
    final existing = await getSavedLocations();

    final existingGpsEntryIndex = existing.indexWhere((l) => l.id == 'auto_gps');
    SavedLocation? existingGpsEntry;
    if (existingGpsEntryIndex != -1) {
      existingGpsEntry = existing[existingGpsEntryIndex];
    }

    final bool shouldBeCurrent = existingGpsEntry != null
        ? existingGpsEntry.isCurrent
        : !existing.any((l) => l.isCurrent);

    final now = DateTime.now().toIso8601String();

    final sl = SavedLocation(
      lat: lat,
      lon: lon,
      id: 'auto_gps', // ALWAYS a fixed id for the GPS entry
      apiName: name,
      displayName: "বর্তমান অবস্থান",
      displayNameEn: "Current Location",
      upazila: upazila,
      upazilaBn: upazilaBn,
      district: district,
      districtBn: districtBn,
      division: division,
      divisionBn: divisionBn,
      isCurrent: shouldBeCurrent,
      createdAt: existingGpsEntry?.createdAt ?? now,
    );

    if (existingGpsEntryIndex != -1) {
      existing[existingGpsEntryIndex] = sl;
    } else {
      existing.add(sl);
    }
    await _saveLocationList(existing);

    if (shouldBeCurrent) {
      await _prefs.setString(_kLat, lat);
      await _prefs.setString(_kLon, lon);
      await _prefs.setString(_kLocationId, id);
      await _prefs.setString(_kLocationName, name);
      await _prefs.setString(_kLocationUpazila, upazila);
      await _prefs.setString(_kLocationUpazilaBn, upazilaBn);
      await _prefs.setString(_kLocationDistrict, district);
      await _prefs.setString(_kLocationDistrictBn, districtBn);
      await _prefs.setString(_kLocationDivision, division);
      await _prefs.setString(_kLocationDivisionBn, divisionBn);
    }
  }

  Future<void> saveCustomLocation({
    required String lat,
    required String lon,
    required String apiId,
    required String apiName,
    required String displayName,
    required String displayNameEn,
    required String upazila,
    required String upazilaBn,
    required String district,
    required String districtBn,
    required String division,
    required String divisionBn,
    bool setAsCurrent = false,
  }) async {
    final now = DateTime.now().toIso8601String();
    final loc = SavedLocation(
      lat: lat,
      lon: lon,
      id: apiId,
      apiName: apiName,
      displayName: displayName,
      displayNameEn: displayNameEn,
      upazila: upazila,
      upazilaBn: upazilaBn,
      district: district,
      districtBn: districtBn,
      division: division,
      divisionBn: divisionBn,
      isCurrent: setAsCurrent,
      createdAt: now,
    );
    await _addOrUpdateSavedLocation(loc);

    if (setAsCurrent) {
      await _prefs.setString(_kLat, lat);
      await _prefs.setString(_kLon, lon);
      await _prefs.setString(_kLocationId, apiId);
      await _prefs.setString(_kLocationName, apiName);
      await _prefs.setString(_kDisplayName, displayName);
      await _prefs.setString(_kLocationUpazila, upazila);
      await _prefs.setString(_kLocationUpazilaBn, upazilaBn);
      await _prefs.setString(_kLocationDistrict, district);
      await _prefs.setString(_kLocationDistrictBn, districtBn);
      await _prefs.setString(_kLocationDivision, division);
      await _prefs.setString(_kLocationDivisionBn, divisionBn);
    }
  }

  Future<List<SavedLocation>> getSavedLocations() async {
    final raw = _prefs.getStringList(_kSavedLocations) ?? [];
    final list = raw
        .map((e) {
          try {
            return SavedLocation.fromJson(jsonDecode(e) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<SavedLocation>()
        .toList();

    list.sort((a, b) {
      if (a.isCurrent && !b.isCurrent) return -1;
      if (!a.isCurrent && b.isCurrent) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    return list;
  }

  Future<void> deleteSavedLocation(String displayName) async {
    final raw = _prefs.getStringList(_kSavedLocations) ?? [];
    final filtered = raw.where((e) {
      try {
        final m = jsonDecode(e) as Map<String, dynamic>;
        return (m['displayName'] as String) != displayName;
      } catch (_) {
        return true;
      }
    }).toList();
    await _prefs.setStringList(_kSavedLocations, filtered);
  }

  /// Sets a saved location as current by displayName.
  /// isFollowingGPS is true ONLY when the match is the GPS entry
  /// (id == 'auto_gps') - corruption bugfix, do not change this check.
  Future<bool> setCurrentLocationByName(String displayName) async {
    final locations = await getSavedLocations();
    SavedLocation? match;
    for (final l in locations) {
      if (l.displayName == displayName) {
        match = l;
        break;
      }
    }
    if (match == null) return false;

    await setFollowGPS(match.id == 'auto_gps');

    final newMatch = match.copyWith(isCurrent: true);
    await _addOrUpdateSavedLocation(newMatch);

    await _prefs.setString(_kLat, newMatch.lat);
    await _prefs.setString(_kLon, newMatch.lon);
    await _prefs.setString(_kLocationId, newMatch.id);
    await _prefs.setString(_kLocationName, newMatch.apiName);
    await _prefs.setString(_kDisplayName, newMatch.displayName);
    await _prefs.setString(_kLocationUpazila, newMatch.upazila);
    await _prefs.setString(_kLocationUpazilaBn, newMatch.upazilaBn);
    await _prefs.setString(_kLocationDistrict, newMatch.district);
    await _prefs.setString(_kLocationDistrictBn, newMatch.districtBn);
    await _prefs.setString(_kLocationDivision, newMatch.division);
    await _prefs.setString(_kLocationDivisionBn, newMatch.divisionBn);

    return true;
  }

  Future<bool> updateLocationDisplayName(
      String oldDisplayName, String newDisplayName) async {
    try {
      final raw = _prefs.getStringList(_kSavedLocations) ?? [];
      final list = raw.map((e) => SavedLocation.fromJson(jsonDecode(e))).toList();

      final idx = list.indexWhere((l) => l.displayName == oldDisplayName);
      if (idx == -1) return false;

      list[idx] = list[idx].copyWith(
        displayName: newDisplayName,
        displayNameEn: newDisplayName,
      );
      await _saveLocationList(list);

      if (_prefs.getString(_kDisplayName) == oldDisplayName) {
        await _prefs.setString(_kDisplayName, newDisplayName);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _addOrUpdateSavedLocation(SavedLocation loc) async {
    final raw = _prefs.getStringList(_kSavedLocations) ?? [];
    final list = raw.map((e) => SavedLocation.fromJson(jsonDecode(e))).toList();

    if (loc.isCurrent) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].isCurrent) {
          list[i] = list[i].copyWith(isCurrent: false);
        }
      }
    }

    final idx = list.indexWhere((l) => l.displayName == loc.displayName);
    if (idx >= 0) {
      list[idx] = loc;
    } else {
      list.add(loc);
    }
    await _saveLocationList(list);
  }

  Future<void> _saveLocationList(List<SavedLocation> locations) async {
    final serialized = locations.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_kSavedLocations, serialized);
  }

  // ── Live weather cache (for instant video/type display on re-open) ──

  Future<void> cacheLiveWeather({
    required String videoUrl,
    required String type,
  }) async {
    await _prefs.setString(_kLiveVideoUrl, videoUrl);
    await _prefs.setString(_kLiveWeatherType, type);
  }

  String get cachedLiveVideoUrl => _prefs.getString(_kLiveVideoUrl) ?? '';
  String get cachedLiveWeatherType => _prefs.getString(_kLiveWeatherType) ?? '';

  Future<void> clearLiveWeatherCache() async {
    await _prefs.remove(_kLiveVideoUrl);
    await _prefs.remove(_kLiveWeatherType);
  }

  /// Narrower than clearLiveWeatherCache - the video is language-independent
  /// (same asset regardless of locale), so a language change should only
  /// invalidate the cached type text, not force a video re-init.
  Future<void> clearLiveWeatherTypeCache() async {
    await _prefs.remove(_kLiveWeatherType);
  }
}
