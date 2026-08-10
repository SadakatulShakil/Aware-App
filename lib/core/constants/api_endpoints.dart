/// TODO: Replace with the official DDM/AWARE API base URL when provided.
class ApiEndpoints {
  ApiEndpoints._();

  static const baseUrl = 'https://rapid.ddm.gov.bd/api';
  static const baseIconUrl = 'https://usf.bmd.gov.bd/src/weather_icon';

  static const weather = '$baseUrl/weather';
  static const alerts = '$baseUrl/alert/current';
  static const alertOngoing = '$baseUrl/alert/ongoing';
  static const fcmTokenUpdate = '$baseUrl/notification/token';
  static const hazardList = '$baseUrl/hazard/list';
  static const ongoingHazard = '$baseUrl/hazard/ongoing';
  static const serviceList = '$baseUrl/service/list';
  static const incidentReportCreate = '$baseUrl/Incidentreport/create';
  static const incidentReportRead = '$baseUrl/Incidentreport/read/';
  static String incidentReportReadById(String id) => '$baseUrl/Incidentreport/read/$id';
  static String incidentReportReal(String id) => '$baseUrl/Incidentreport/real/$id';
  static String incidentReportFake(String id) => '$baseUrl/Incidentreport/fake/$id';

  static const bmdBaseUrl = 'https://usf.bmd.gov.bd/api/app';
  static const bmdForecast = '$bmdBaseUrl/weather/forecast';
  static const bmdLiveWeather = '$bmdBaseUrl/weather/liveweather';
  static const notificationList = '$baseUrl/notification/list';
}
