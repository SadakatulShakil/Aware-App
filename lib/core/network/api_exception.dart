class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  factory ApiException.noInternet() =>
      const ApiException('No internet connection');

  factory ApiException.timeout() =>
      const ApiException('Request timed out. Please try again.');

  factory ApiException.server(int code, String body) =>
      ApiException('Server error ($code)', code);

  factory ApiException.parsing() =>
      const ApiException('Failed to parse server response');

  @override
  String toString() => 'ApiException($statusCode): $message';
}
