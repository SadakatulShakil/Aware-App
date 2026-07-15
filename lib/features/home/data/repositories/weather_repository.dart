import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/forecast_model.dart';
import '../models/live_weather_model.dart';

/// BMD forecast + live-weather source. Ported 1:1 - same endpoints,
/// same Accept-Language header, same "empty string = don't override" rule.
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
      final json = await _api.get(
        ApiEndpoints.bmdForecast,
        query: query,
        headers: {'Accept-Language': lang},
      );
      return WeatherForecastModel.fromJson(json);
    } catch (e) {
      AppLogger.w('WeatherRepository.getForecast failed: $uri (Accept-Language=$lang) -> $e');
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
}
