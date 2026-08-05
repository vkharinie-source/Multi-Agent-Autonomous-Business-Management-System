import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../exceptions/api_exception.dart';

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  static const Duration _timeoutDuration = Duration(seconds: 30);

  Map<String, String> _headers({String? accessToken}) {
    return {
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.contentTypeHeader: 'application/json',
      if (accessToken != null && accessToken.isNotEmpty)
        HttpHeaders.authorizationHeader: 'Bearer $accessToken',
    };
  }

  Future<dynamic> get(String endpoint, {String? accessToken}) async {
    try {
      final response = await http
          .get(
            ApiConfig.buildUri(endpoint),
            headers: _headers(accessToken: accessToken),
          )
          .timeout(_timeoutDuration);

      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        message:
            'Cannot connect to the server. Check your internet and backend connection.',
      );
    } on http.ClientException {
      throw const ApiException(
        message: 'Unable to communicate with the server.',
      );
    } on FormatException {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(message: 'Unexpected error: $error');
    }
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async {
    try {
      final response = await http
          .post(
            ApiConfig.buildUri(endpoint),
            headers: _headers(accessToken: accessToken),
            body: jsonEncode(body ?? <String, dynamic>{}),
          )
          .timeout(_timeoutDuration);

      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        message:
            'Cannot connect to the server. Check your internet and backend connection.',
      );
    } on http.ClientException {
      throw const ApiException(
        message: 'Unable to communicate with the server.',
      );
    } on FormatException {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(message: 'Unexpected error: $error');
    }
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async {
    try {
      final response = await http
          .put(
            ApiConfig.buildUri(endpoint),
            headers: _headers(accessToken: accessToken),
            body: jsonEncode(body ?? <String, dynamic>{}),
          )
          .timeout(_timeoutDuration);

      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        message:
            'Cannot connect to the server. Check your internet and backend connection.',
      );
    } on http.ClientException {
      throw const ApiException(
        message: 'Unable to communicate with the server.',
      );
    } on FormatException {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(message: 'Unexpected error: $error');
    }
  }

  dynamic _handleResponse(http.Response response) {
    dynamic responseData;

    if (response.body.trim().isNotEmpty) {
      try {
        responseData = jsonDecode(response.body);
      } on FormatException {
        throw ApiException(
          message: 'Server returned an invalid response.',
          statusCode: response.statusCode,
          data: response.body,
        );
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData;
    }

    String errorMessage = 'Request failed';

    if (responseData is Map<String, dynamic>) {
      final dynamic detail = responseData['detail'];
      final dynamic message = responseData['message'];

      if (detail is String && detail.isNotEmpty) {
        errorMessage = detail;
      } else if (message is String && message.isNotEmpty) {
        errorMessage = message;
      } else if (detail is List && detail.isNotEmpty) {
        final dynamic firstError = detail.first;

        if (firstError is Map<String, dynamic>) {
          errorMessage = firstError['msg']?.toString() ?? 'Validation failed';
        }
      }
    }

    throw ApiException(
      message: errorMessage,
      statusCode: response.statusCode,
      data: responseData,
    );
  }
}
