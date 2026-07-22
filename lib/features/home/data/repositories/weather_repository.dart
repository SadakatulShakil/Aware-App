import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/device_info.dart';
import '../models/forecast_model.dart';
import '../models/live_weather_model.dart';

/// BMD forecast + live-weather source. Ported 1:1 - same endpoints,
/// same "empty string = don't override" rule. The language header is
/// applied globally by ApiClient - not set here.
class WeatherRepository {
  final ApiClient _api;

  WeatherRepository(this._api);

  Future<WeatherForecastModel?> getForecast({
    required String lat,
    required String lon,
    required String lang,
  }) async {
    final query = {'type': 'point', 'lat': lat, 'lon': lon};
    final uri = Uri.parse(ApiEndpoints.bmdForecast).replace(queryParameters: query);
    try {
      final json = await _api.get(ApiEndpoints.bmdForecast, query: query);
      return WeatherForecastModel.fromJson(json);
    } catch (e) {
      AppLogger.w('WeatherRepository.getForecast failed: $uri (lang=$lang) -> $e');
      return null;
    }
  }

  /// Never throws - empty-string fields in [LiveWeatherModel] mean
  /// "don't override the forecast value", so a failed call safely
  /// resolves to LiveWeatherModel.empty().
  Future<LiveWeatherModel> getLiveWeather({
    required String lat,
    required String lon,
  }) async {
    try {
      final json = await _api.get(
        ApiEndpoints.bmdLiveWeather,
        query: {'lat': lat, 'lon': lon},
      );
      return LiveWeatherModel.fromJson(json);
    } catch (_) {
      return LiveWeatherModel.empty();
    }
  }

  /// Uploads the FCM token to the DDM backend so it can target this device
  /// by its last-known lat/lon. Ported 1:1 from BMD - never throws, a failed
  /// send just means the next background refresh retries it.
  Future<void> updateFcmToken({
    required String token,
    required String? lat,
    required String? lon,
  }) async {
    try {
      final deviceInfo = await getDeviceInfo();
      final body = {'token': token, 'lat': lat, 'lon': lon, ...deviceInfo};
      await _api.post(ApiEndpoints.fcmTokenUpdate, body: body);
    } catch (e) {
      AppLogger.w('FCM token update failed: $e');
    }
  }
}
