import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../services/user_pref_service.dart';
import '../utils/app_logger.dart';
import 'api_exception.dart';

/// Single gateway for all HTTP calls.
/// Every repository must go through this class - never call http directly
/// (FFWC 403 lesson: bypassing the client bypasses the security headers).
class ApiClient {
  static const Duration _timeout = Duration(seconds: 30);

  /// Read fresh on every call (never cached) so an instant language toggle
  /// is reflected in the very next request - no repository may set this
  /// header itself.
  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Language': Get.find<UserPrefService>().appLanguage,
        // Add auth / api-key headers here in ONE place when backend requires.
      };

  Future<dynamic> get(String url,
      {Map<String, String>? query, Map<String, String>? headers}) async {
    final uri = Uri.parse(url).replace(queryParameters: query);
    AppLogger.d('GET $uri');
    try {
      final res = await http
          .get(uri, headers: {..._headers(), ...?headers})
          .timeout(_timeout);
      return _process(res);
    } on SocketException {
      throw ApiException.noInternet();
    } on TimeoutException {
      throw ApiException.timeout();
    }
  }

  Future<dynamic> post(String url, {Map<String, dynamic>? body}) async {
    AppLogger.d('POST $url');
    try {
      final res = await http
          .post(Uri.parse(url), headers: _headers(), body: jsonEncode(body))
          .timeout(_timeout);
      return _process(res);
    } on SocketException {
      throw ApiException.noInternet();
    } on TimeoutException {
      throw ApiException.timeout();
    }
  }

  dynamic _process(http.Response res) {
    AppLogger.d('<- ${res.statusCode} ${res.request?.url.path}');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return <String, dynamic>{};
      try {
        return jsonDecode(res.body);
      } catch (_) {
        throw ApiException.parsing();
      }
    }
    throw ApiException.server(res.statusCode, res.body);
  }
}
