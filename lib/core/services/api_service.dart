import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../exceptions/api_exception.dart';
import 'secure_storage_service.dart';

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  final http.Client _client = http.Client();

  final SecureStorageService _secureStorageService =
      SecureStorageService.instance;

  static const Duration _requestTimeout = Duration(seconds: 60);

  Future<Map<String, dynamic>> get({
    required String endpoint,
    String? accessToken,
    bool requiresAuth = false,
  }) async {
    final Map<String, String> headers = await _buildHeaders(
      accessToken: accessToken,
      requiresAuth: requiresAuth,
    );

    try {
      final http.Response response = await _client
          .get(ApiConfig.uri(endpoint), headers: headers)
          .timeout(_requestTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(message: 'The server took too long to respond.');
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(message: 'Unable to connect to the server: $error');
    }
  }

  Future<Map<String, dynamic>> post({
    required String endpoint,
    Map<String, dynamic>? body,
    String? accessToken,
    bool requiresAuth = false,
  }) async {
    final Map<String, String> headers = await _buildHeaders(
      accessToken: accessToken,
      requiresAuth: requiresAuth,
    );

    try {
      final http.Response response = await _client
          .post(
            ApiConfig.uri(endpoint),
            headers: headers,
            body: jsonEncode(body ?? <String, dynamic>{}),
          )
          .timeout(_requestTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(message: 'The server took too long to respond.');
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(message: 'Unable to connect to the server: $error');
    }
  }

  Future<Map<String, dynamic>> put({
    required String endpoint,
    Map<String, dynamic>? body,
    String? accessToken,
    bool requiresAuth = false,
  }) async {
    final Map<String, String> headers = await _buildHeaders(
      accessToken: accessToken,
      requiresAuth: requiresAuth,
    );

    try {
      final http.Response response = await _client
          .put(
            ApiConfig.uri(endpoint),
            headers: headers,
            body: jsonEncode(body ?? <String, dynamic>{}),
          )
          .timeout(_requestTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(message: 'The server took too long to respond.');
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(message: 'Unable to connect to the server: $error');
    }
  }

  Future<Map<String, dynamic>> delete({
    required String endpoint,
    Map<String, dynamic>? body,
    String? accessToken,
    bool requiresAuth = false,
  }) async {
    final Map<String, String> headers = await _buildHeaders(
      accessToken: accessToken,
      requiresAuth: requiresAuth,
    );

    try {
      final http.Response response = await _client
          .delete(
            ApiConfig.uri(endpoint),
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(_requestTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(message: 'The server took too long to respond.');
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(message: 'Unable to connect to the server: $error');
    }
  }

  Future<Map<String, String>> _buildHeaders({
    required String? accessToken,
    required bool requiresAuth,
  }) async {
    final Map<String, String> headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    String? token = accessToken?.trim();

    if ((token == null || token.isEmpty) && requiresAuth) {
      token = await _secureStorageService.readAccessToken();
    }

    if (requiresAuth && (token == null || token.isEmpty)) {
      throw const ApiException(
        message: 'Login session was not found. Please sign in again.',
        statusCode: 401,
      );
    }

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final dynamic decodedBody = _decodeResponseBody(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decodedBody is Map<String, dynamic>) {
        return decodedBody;
      }

      if (decodedBody is Map) {
        return Map<String, dynamic>.from(decodedBody);
      }

      return <String, dynamic>{'data': decodedBody};
    }

    throw ApiException(
      message: _extractErrorMessage(
        statusCode: response.statusCode,
        decodedBody: decodedBody,
      ),
      statusCode: response.statusCode,
      responseBody: decodedBody,
    );
  }

  dynamic _decodeResponseBody(String responseBody) {
    if (responseBody.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      return jsonDecode(responseBody);
    } catch (_) {
      return <String, dynamic>{'raw_response': responseBody};
    }
  }

  String _extractErrorMessage({
    required int statusCode,
    required dynamic decodedBody,
  }) {
    if (decodedBody is Map) {
      final dynamic detail = decodedBody['detail'];
      final dynamic message = decodedBody['message'];

      if (detail is String && detail.trim().isNotEmpty) {
        return detail.trim();
      }

      if (detail is List && detail.isNotEmpty) {
        final List<String> errors = detail.map((dynamic item) {
          if (item is Map) {
            return item['msg']?.toString() ?? 'Invalid request value.';
          }

          return item.toString();
        }).toList();

        return errors.join('\n');
      }

      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }

    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check the entered details.';

      case 401:
        return 'Invalid login session. Please sign in again.';

      case 403:
        return 'You do not have permission to perform this action.';

      case 404:
        return 'The requested information was not found.';

      case 409:
        return 'This information already exists.';

      case 422:
        return 'Some required information is missing or invalid.';

      case 500:
        return 'The backend encountered an error.';

      default:
        return 'Request failed with status code $statusCode.';
    }
  }

  void close() {
    _client.close();
  }
}
