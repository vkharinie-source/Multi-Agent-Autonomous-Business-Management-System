class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.responseBody,
  });

  final String message;
  final int? statusCode;
  final dynamic responseBody;

  @override
  String toString() {
    return message;
  }
}
