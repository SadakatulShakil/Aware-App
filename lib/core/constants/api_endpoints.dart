/// TODO: Replace with the official DDM/AWARE API base URL when provided.
class ApiEndpoints {
  ApiEndpoints._();

  static const baseUrl = 'https://rapid.ddm.gov.bd/api';

  // Planned endpoints - wire these when backend team shares the contract.
  static const weather = '$baseUrl/weather';
  static const alerts = '$baseUrl/alerts';
  static const hazards = '$baseUrl/hazards';
  static const services = '$baseUrl/services';
  static const alertOngoing = '$baseUrl/alert/ongoing';

  // ---- BMD live weather source (ported 1:1 from BMD Abohawa) ----
  static const bmdBaseUrl = 'https://usf.bmd.gov.bd/api/app';
  static const bmdForecast = '$bmdBaseUrl/weather/forecast';
  static const bmdLiveWeather = '$bmdBaseUrl/weather/liveweather';
  static const bmdNotificationList = '$bmdBaseUrl/notification/list';
}
