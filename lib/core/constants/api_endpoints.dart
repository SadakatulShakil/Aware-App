/// TODO: Replace with the official DDM/AWARE API base URL when provided.
class ApiEndpoints {
  ApiEndpoints._();

  static const baseUrl = 'https://rapid.ddm.gov.bd/api';
  static const baseIconUrl = 'https://usf.bmd.gov.bd/src/weather_icon';

  static const weather = '$baseUrl/weather';
  static const alerts = '$baseUrl/alerts';
  static const alertOngoing = '$baseUrl/alert/ongoing';
  static const fcmTokenUpdate = '$baseUrl/notification/token';
  static const hazardList = '$baseUrl/hazard/list';
  static const serviceList = '$baseUrl/service/list';

  static const bmdBaseUrl = 'https://usf.bmd.gov.bd/api/app';
  static const bmdForecast = '$bmdBaseUrl/weather/forecast';
  static const bmdLiveWeather = '$bmdBaseUrl/weather/liveweather';
  static const bmdNotificationList = '$bmdBaseUrl/notification/list';
}
