import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/user_pref_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../hazard/data/models/hazard_entity.dart';
import '../../../hazard/data/repositories/hazard_repository.dart';
import '../../data/models/alert_model.dart';
import '../../data/models/forecast_model.dart';
import '../../data/models/saved_location_model.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/repositories/weather_local_repository.dart';
import '../../data/repositories/weather_repository.dart';
import '../pages/location_selection_page.dart';

class HomeController extends GetxController {
  final HomeRepository _homeRepo;
  final HazardRepository _hazardRepo;
  final WeatherRepository _weatherRepo;
  final WeatherLocalRepository _localRepo;

  final UserPrefService userService = Get.find<UserPrefService>();
  final LocationService _locationService = LocationService.instance;

  HomeController(
    this._homeRepo,
    this._hazardRepo,
    this._weatherRepo,
    this._localRepo,
  );

  // ── Existing AWARE sections (untouched behavior) ──
  final RxList<AlertModel> alerts = <AlertModel>[].obs;
  final RxList<HazardEntity> hazards = <HazardEntity>[].obs;
  final RxBool isAlertsLoading = false.obs;
  final RxBool alertsLoadError = false.obs;

  // ── Weather / location state (ported from BMD HomeController) ──
  final RxBool isLoaded = false.obs;
  final RxBool isForecastLoading = false.obs;
  final RxBool isForecastFetched = false.obs;
  final RxBool isLocationSwitching = false.obs;
  final RxBool isLiveWeatherLoading = false.obs;
  final RxBool hasCachedOrLiveData = false.obs;
  final Rxn<WeatherForecastModel> forecast = Rxn<WeatherForecastModel>();

  final RxString currentLocationId = ''.obs;
  final RxString currentLocationName = ''.obs;
  final RxString lat = ''.obs;
  final RxString lon = ''.obs;
  final RxList<SavedLocation> savedLocations = <SavedLocation>[].obs;

  final RxString liveWeatherType = ''.obs; // non-empty overrides forecast type
  final RxString liveVideoUrl = ''.obs; // non-empty = show video background
  final RxString liveRainfall = ''.obs;
  final RxString liveTemp = ''.obs;
  final RxString liveFeelsLike = ''.obs;
  final RxString liveIcon = ''.obs;
  int _liveWeatherRequestId = 0;

  final RxBool locationPermissionGranted = true.obs;
  final RxBool locationServiceEnabled = true.obs;
  final RxBool isLocationUpdating = false.obs;
  final RxBool isSyncingLocation = false.obs;

  DateTime? _lastGPSFetchTime;
  double? _lastLat;
  double? _lastLon;
  static const Duration _gpsRefreshInterval = Duration(minutes: 30);
  static const double _gpsRefreshDistanceMeters = 5000;

  StreamSubscription<ServiceStatus>? _serviceStatusSubscription;

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  @override
  void onReady() {
    super.onReady();
    final coldNoData = forecast.value == null;
    Future.delayed(
      Duration(seconds: coldNoData ? 1 : 3),
      () => _autoSyncGPSLocation(),
    );
    _startLocationServiceListener();
    NotificationService.instance.handlePendingFcmNavigation();
  }

  @override
  void onClose() {
    _serviceStatusSubscription?.cancel();
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> initData() async {
    await _refreshLocationStatus();
    await getSharedPrefDataFromCache();
    isLoaded.value = true;
    _refreshAllDataInBackground();
  }

  /// Loads forecast/location state from local cache only - no network.
  Future<void> getSharedPrefDataFromCache() async {
    currentLocationId.value = userService.locationId ?? '';

    // Active coords come from the isCurrent saved-location entry -
    // authoritative source of truth (never trust LAT/LON keys directly
    // when a custom location might be active).
    final savedLocs = await userService.getSavedLocations();
    final activeLoc = savedLocs.firstWhereOrNull((l) => l.isCurrent);
    if (activeLoc != null && activeLoc.id != 'auto_gps' && activeLoc.lat.isNotEmpty) {
      lat.value = activeLoc.lat;
      lon.value = activeLoc.lon;
    } else {
      lat.value = userService.lat ?? '';
      lon.value = userService.lon ?? '';
    }
    savedLocations.assignAll(savedLocs);

    final cached = await _localRepo.getCachedForecast(lat.value, lon.value);
    if (cached != null) {
      forecast.value = cached;
      currentLocationName.value = cached.result?.location?.locationName ?? '';
      isForecastFetched.value = true;
      hasCachedOrLiveData.value = true;
    }

    // Cached live weather - starts video instantly without waiting
    // for the live API to return.
    liveVideoUrl.value = userService.cachedLiveVideoUrl;
    liveWeatherType.value = userService.cachedLiveWeatherType;

    // Cached alerts - carousel shows the last-known list instantly;
    // fetchAlerts() replaces this with fresh data in the background.
    final cachedAlerts = await _localRepo.getCachedAlerts();
    if (cachedAlerts != null && cachedAlerts.isNotEmpty) {
      alerts.assignAll(cachedAlerts);
    }
  }

  void _refreshAllDataInBackground() {
    Future.microtask(() async {
      final hasCoords = lat.value.isNotEmpty && lon.value.isNotEmpty;
      await Future.wait([
        if (hasCoords) getForecast(lat.value, lon.value),
        if (hasCoords) fetchLiveWeather(lat.value, lon.value),
        fetchAlerts(),
        fetchHazards(),
      ]);
    });
  }

  /// Re-derives coords then refetches forecast + live weather. Used after
  /// a location switch or a GPS update.
  Future<void> getSharedPrefData() async {
    currentLocationId.value = userService.locationId ?? '';

    final savedLocs = await userService.getSavedLocations();
    final activeLoc = savedLocs.firstWhereOrNull((l) => l.isCurrent);
    if (activeLoc != null && activeLoc.id != 'auto_gps' && activeLoc.lat.isNotEmpty) {
      lat.value = activeLoc.lat;
      lon.value = activeLoc.lon;
    } else {
      lat.value = userService.lat ?? '';
      lon.value = userService.lon ?? '';
    }

    await Future.wait([
      getForecast(lat.value, lon.value),
      fetchLiveWeather(lat.value, lon.value),
    ]);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // WEATHER
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> getForecast(String lat, String lon) async {
    if (lat.isEmpty || lon.isEmpty) return;
    isForecastLoading.value = true;
    try {
      final cachedData = await _localRepo.getCachedForecast(lat, lon);
      // Apply cache ONLY on the cold path or during an explicit location
      // switch (loader covers the card) - never re-apply a possibly-older
      // cache snapshot over already-displayed fresh data on pull-to-refresh.
      final shouldApplyCache = forecast.value == null || isLocationSwitching.value;
      if (cachedData != null && shouldApplyCache) {
        forecast.value = cachedData;
        currentLocationName.value =
            cachedData.result?.location?.locationName ?? currentLocationName.value;
        isForecastFetched.value = true;
      }

      final result = await _weatherRepo.getForecast(
        lat: lat,
        lon: lon,
        lang: userService.appLanguage,
      );

      if (result != null) {
        forecast.value = result;
        currentLocationName.value =
            result.result?.location?.locationName ?? currentLocationName.value;
        isForecastFetched.value = true;
        hasCachedOrLiveData.value = true;
        await _localRepo.cacheForecast(lat, lon, result);
      } else if (cachedData == null) {
        isForecastFetched.value = false;
      }
    } catch (e) {
      AppLogger.e('getForecast failed', e);
      if (forecast.value == null) isForecastFetched.value = false;
    } finally {
      isForecastLoading.value = false;
    }
  }

  Future<void> fetchLiveWeather(String lat, String lon) async {
    if (lat.isEmpty || lon.isEmpty) return;

    final myId = ++_liveWeatherRequestId;
    isLiveWeatherLoading.value = true;

    try {
      final live = await _weatherRepo
          .getLiveWeather(lat: lat, lon: lon)
          .timeout(const Duration(seconds: 5));

      if (myId != _liveWeatherRequestId) return; // stale - newer call active

      isLiveWeatherLoading.value = false;
      liveWeatherType.value = live.type;
      liveVideoUrl.value = live.videoUrl;
      liveRainfall.value = live.rainfall;
      liveTemp.value = live.temp;
      liveFeelsLike.value = live.feelsLike;
      liveIcon.value = live.icon;

      await userService.cacheLiveWeather(videoUrl: live.videoUrl, type: live.type);
    } catch (_) {
      if (myId != _liveWeatherRequestId) return;
      isLiveWeatherLoading.value = false;
    }
  }

  Future<void> fetchAlerts() async {
    isAlertsLoading.value = true;
    try {
      final fresh = await _homeRepo.getAlerts(lang: userService.appLanguage);
      alerts.assignAll(fresh);
      alertsLoadError.value = false;
      await _localRepo.cacheAlerts(fresh);
    } catch (e) {
      // Network/API failure - keep whatever is currently displayed
      // (cached data applied in getSharedPrefDataFromCache, or the
      // previous successful fetch).
      if (alerts.isEmpty) alertsLoadError.value = true;
      AppLogger.e('fetchAlerts failed', e);
    } finally {
      isAlertsLoading.value = false;
    }
  }

  Future<void> fetchHazards() async {
    try {
      hazards.assignAll(await _hazardRepo.getHazards());
    } catch (e) {
      AppLogger.e('fetchHazards failed', e);
    }
  }

  Future<void> onRefresh() async {
    await Future.wait([
      if (lat.value.isNotEmpty) getForecast(lat.value, lon.value),
      if (lat.value.isNotEmpty) fetchLiveWeather(lat.value, lon.value),
      fetchAlerts(),
      fetchHazards(),
    ]);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOCATION - PERMISSION + SERVICE STATUS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _refreshLocationStatus() async {
    final hasCompletedSetup =
        (userService.lat != null && userService.lat!.isNotEmpty) ||
            savedLocations.isNotEmpty;
    if (!hasCompletedSetup) {
      locationPermissionGranted.value = true;
      locationServiceEnabled.value = true;
      return;
    }
    locationServiceEnabled.value = await _locationService.isLocationServiceEnabled();
    locationPermissionGranted.value = await _locationService.isPermissionGranted();
  }

  Future<void> requestLocationFromBanner() async {
    final serviceOn = await _locationService.isLocationServiceEnabled();
    if (!serviceOn) {
      await Geolocator.openLocationSettings();
      await _refreshLocationStatus();
      return;
    }
    final granted = await _locationService.requestPermissionWithRationale();
    if (granted) {
      locationPermissionGranted.value = true;
      locationServiceEnabled.value = true;
      await _fetchGPSAndUpdateWeather();
    } else {
      await _refreshLocationStatus();
    }
  }

  Future<void> onAppResumed() async {
    final wasServiceOn = locationServiceEnabled.value;
    final wasPermissionGranted = locationPermissionGranted.value;

    await _refreshLocationStatus();

    final justEnabled = (!wasServiceOn || !wasPermissionGranted) &&
        locationServiceEnabled.value &&
        locationPermissionGranted.value;

    if (justEnabled) {
      final resumeLocs = await userService.getSavedLocations();
      final hasGpsCurrent = resumeLocs.any((l) => l.id == 'auto_gps' && l.isCurrent);
      if (hasGpsCurrent) {
        await _fetchGPSAndUpdateWeather();
      } else {
        await _autoSyncGPSLocation();
      }
      return;
    }

    if (locationServiceEnabled.value && locationPermissionGranted.value) {
      await _refreshIfNeeded();
    }
  }

  /// 30-min time OR 5km distance threshold - only for GPS-based current
  /// location. A manually-selected fixed location is never auto-refreshed.
  Future<void> _refreshIfNeeded() async {
    final locations = await userService.getSavedLocations();
    final hasGpsCurrent = locations.any((l) => l.id == 'auto_gps' && l.isCurrent);
    if (!hasGpsCurrent) return;

    final now = DateTime.now();
    final lastFetch = _lastGPSFetchTime;
    final timeSinceLastFetch =
        lastFetch == null ? const Duration(days: 999) : now.difference(lastFetch);

    if (timeSinceLastFetch >= _gpsRefreshInterval) {
      await _fetchGPSAndUpdateWeather();
      return;
    }

    if (_lastLat != null && _lastLon != null) {
      try {
        final currentPosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
        ).timeout(const Duration(seconds: 5));

        final distanceMoved = Geolocator.distanceBetween(
          _lastLat!,
          _lastLon!,
          currentPosition.latitude,
          currentPosition.longitude,
        );
        if (distanceMoved >= _gpsRefreshDistanceMeters) {
          await _fetchGPSAndUpdateWeather();
        }
      } catch (_) {
        // GPS timeout etc - time threshold will catch it next time.
      }
    }
  }

  void _startLocationServiceListener() {
    _serviceStatusSubscription?.cancel();
    _serviceStatusSubscription =
        Geolocator.getServiceStatusStream().listen((status) async {
      final isOn = status == ServiceStatus.enabled;
      locationServiceEnabled.value = isOn;
      if (isOn) {
        final granted = await _locationService.isPermissionGranted();
        locationPermissionGranted.value = granted;
        if (granted) {
          if (userService.isFollowingGPS) {
            await _fetchGPSAndUpdateWeather();
          } else {
            await _autoSyncGPSLocation();
          }
        }
      }
    });
  }

  Future<void> _fetchGPSAndUpdateWeather() async {
    if (isLocationUpdating.value) return;
    isLocationUpdating.value = true;
    try {
      final success = await _locationService.getLocation(
        onSettingsOpened: () {},
        timeoutSeconds: 10,
        isSilent: false,
      );
      if (success) {
        _recordGPSFetch();
        await loadSavedLocations();
        final gpsCurrent = savedLocations.any((l) => l.id == 'auto_gps' && l.isCurrent);
        if (gpsCurrent) await getSharedPrefData();
      }
    } finally {
      isLocationUpdating.value = false;
      await _refreshLocationStatus();
    }
  }

  /// Silent cold-start GPS sync - never shows dialogs. If it fails and
  /// there is nothing on screen yet, falls back to the add-location flow.
  Future<void> _autoSyncGPSLocation() async {
    if (isSyncingLocation.value) return;
    isSyncingLocation.value = true;
    try {
      final success = await _locationService.getLocation(
        onSettingsOpened: () {},
        timeoutSeconds: 10,
        isSilent: true,
      );

      if (success) {
        _recordGPSFetch();
        await loadSavedLocations();
        final gpsCurrent = savedLocations.any((l) => l.id == 'auto_gps' && l.isCurrent);
        final needsFirstLoad =
            forecast.value == null && lat.value.isNotEmpty && lon.value.isNotEmpty;
        if ((gpsCurrent || needsFirstLoad) && !isLocationSwitching.value) {
          await getSharedPrefData();
        }
      } else if (forecast.value == null && savedLocations.isEmpty) {
        await openAddLocationFlow();
      }
    } finally {
      isSyncingLocation.value = false;
    }
  }

  /// Called from the header's "Retry" button. If we have coordinates,
  /// this is a plain data refresh. If we don't (permission denied / GPS
  /// never resolved), retrying the same forecast call would be a no-op
  /// - so resolve a location first, falling back to the manual picker.
  Future<void> retryLoadingData() async {
    if (lat.value.isEmpty || lon.value.isEmpty) {
      if (!isSyncingLocation.value) await _autoSyncGPSLocation();
      if (lat.value.isEmpty || lon.value.isEmpty) {
        await openAddLocationFlow();
      }
    } else {
      await onRefresh();
    }
  }

  void _recordGPSFetch() {
    _lastGPSFetchTime = DateTime.now();
    final latVal = double.tryParse(userService.lat ?? '');
    final lonVal = double.tryParse(userService.lon ?? '');
    if (latVal != null && lonVal != null) {
      _lastLat = latVal;
      _lastLon = lonVal;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOCATION PICKER
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadSavedLocations() async {
    try {
      savedLocations.assignAll(await userService.getSavedLocations());
    } catch (e) {
      AppLogger.e('loadSavedLocations failed', e);
    }
  }

  Future<void> openLocationSelector() async {
    await loadSavedLocations();
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        height: MediaQuery.of(Get.context!).size.height * 0.6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 8, bottom: 8),
              child: Row(
                children: [
                  Text(
                    'location_list_title'.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Obx(() {
                if (savedLocations.isEmpty) {
                  return Center(child: Text('no_data'.tr));
                }
                final gpsLocation =
                    savedLocations.firstWhereOrNull((l) => l.id == 'auto_gps');
                final customLocations =
                    savedLocations.where((l) => l.id != 'auto_gps').toList();

                return ListView(
                  children: [
                    if (gpsLocation != null) ...[
                      _buildLocationTile(gpsLocation, isGps: true),
                      Container(height: 5, color: Colors.grey.shade200),
                    ],
                    for (final loc in customLocations) ...[
                      _buildLocationTile(loc, isGps: false),
                      const Divider(height: 1),
                    ],
                    ListTile(
                      leading: const Icon(Icons.add_location_alt_outlined, color: Colors.blue),
                      title: Text(
                        'add_location'.tr,
                        style: const TextStyle(color: Colors.blue),
                      ),
                      onTap: () async {
                        Get.back();
                        await openAddLocationFlow();
                      },
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationTile(SavedLocation loc, {required bool isGps}) {
    final isBn = userService.isBangla;
    final isSelected = loc.displayName == currentLocationName.value || loc.isCurrent;
    final subtitle = isBn
        ? '${loc.upazilaBn}, ${loc.districtBn}'
        : '${loc.upazila}, ${loc.district}';

    return InkWell(
      onTap: () async => await selectSavedLocation(loc),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              isGps ? Icons.gps_fixed : Icons.place,
              color: isSelected ? Colors.green : Colors.grey,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isBn ? loc.displayName : loc.displayNameEn,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: Icon(Icons.check_circle, color: Colors.green, size: 20),
              ),
            if (!isGps)
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                iconSize: 20,
                onSelected: (value) async {
                  if (value == 'delete') {
                    await userService.deleteSavedLocation(loc.displayName);
                    await loadSavedLocations();
                  } else if (value == 'edit') {
                    final textController = TextEditingController(
                        text: isBn ? loc.displayName : loc.displayNameEn);
                    final newName = await Get.dialog<String>(
                      AlertDialog(
                        title: Text('rename_location'.tr),
                        content: TextField(controller: textController, autofocus: true),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(result: null),
                            child: Text('cancel'.tr),
                          ),
                          ElevatedButton(
                            onPressed: () => Get.back(result: textController.text.trim()),
                            child: Text('save'.tr),
                          ),
                        ],
                      ),
                    );
                    if (newName != null && newName.isNotEmpty && newName != loc.displayName) {
                      final ok =
                          await userService.updateLocationDisplayName(loc.displayName, newName);
                      if (ok) await loadSavedLocations();
                    }
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Text('edit'.tr)),
                  if (!isSelected)
                    PopupMenuItem(value: 'delete', child: Text('delete'.tr)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> selectSavedLocation(SavedLocation loc) async {
    try {
      final ok = await userService.setCurrentLocationByName(loc.displayName);
      if (!ok) {
        Get.back();
        return;
      }

      currentLocationName.value =
          userService.isBangla ? loc.displayName : loc.displayNameEn;

      // Close the picker immediately - otherwise it stays open (covering
      // the bottom ~60% of the screen) for the whole fetch and the
      // header's switching loader is never actually seen by the user.
      Get.back();

      isLocationSwitching.value = true;
      _liveWeatherRequestId++;
      liveVideoUrl.value = '';
      liveWeatherType.value = '';
      liveRainfall.value = '';
      liveTemp.value = '';
      liveFeelsLike.value = '';
      liveIcon.value = '';
      await userService.clearLiveWeatherCache();

      await getSharedPrefData();
      await loadSavedLocations();

      isLocationSwitching.value = false;
    } catch (e) {
      isLocationSwitching.value = false;
      AppLogger.e('selectSavedLocation failed', e);
    }
  }

  Future<void> openAddLocationFlow() async {
    final item = await Get.to<dynamic>(() => const LocationSelectionPage());
    if (item == null) return;

    final latStr = (item.lat as num).toStringAsFixed(5);
    final lonStr = (item.lng as num).toStringAsFixed(5);
    final nameEn = '${item.name},${item.district}';
    final nameBn = '${item.nameBn},${item.districtBn}';

    final fetched = await _fetchLocationDetails(
      lat: latStr,
      lon: lonStr,
      displayNameFallback: nameEn,
      displayNameFallbackBn: nameBn,
    );

    if (fetched != null) {
      await userService.saveCustomLocation(
        lat: fetched.lat,
        lon: fetched.lon,
        apiId: fetched.id,
        apiName: fetched.apiName,
        displayName: fetched.displayName,
        displayNameEn: fetched.displayNameEn,
        upazila: fetched.upazila,
        upazilaBn: fetched.upazilaBn,
        district: fetched.district,
        districtBn: fetched.districtBn,
        division: fetched.division,
        divisionBn: fetched.divisionBn,
        setAsCurrent: true,
      );
      await loadSavedLocations();
      await getSharedPrefData();
    }
  }

  Future<SavedLocation?> _fetchLocationDetails({
    required String lat,
    required String lon,
    required String displayNameFallback,
    required String displayNameFallbackBn,
  }) async {
    final result = await _weatherRepo.getForecast(
      lat: lat,
      lon: lon,
      lang: userService.appLanguage,
    );
    final loc = result?.result?.location;
    final apiName = loc?.locationName ?? displayNameFallback;
    return SavedLocation(
      lat: lat,
      lon: lon,
      id: loc?.id ?? '',
      apiName: apiName,
      displayName: displayNameFallbackBn.isNotEmpty ? displayNameFallbackBn : apiName,
      displayNameEn: displayNameFallback.isNotEmpty ? displayNameFallback : apiName,
      upazila: loc?.upazila ?? '',
      upazilaBn: loc?.upazilaBn ?? '',
      district: loc?.district ?? '',
      districtBn: loc?.districtBn ?? '',
      division: loc?.division ?? '',
      divisionBn: loc?.divisionBn ?? '',
      isCurrent: true,
      createdAt: DateTime.now().toIso8601String(),
    );
  }
}
