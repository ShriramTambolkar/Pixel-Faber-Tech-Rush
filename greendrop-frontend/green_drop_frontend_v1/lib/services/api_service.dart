import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  static const _timeout = Duration(seconds: 15);
  static const _jsonHeaders = {'Content-Type': 'application/json'};

  static Uri _uri(String path) => Uri.parse('$baseUrl$path');

  static Future<http.Response> post(String path, Map<String, dynamic> body) =>
      http.post(_uri(path), headers: _jsonHeaders, body: jsonEncode(body)).timeout(_timeout);

  static Future<http.Response> get(String path) => http.get(_uri(path)).timeout(_timeout);

  static Future<http.Response> patch(String path, Map<String, dynamic> body) =>
      http.patch(_uri(path), headers: _jsonHeaders, body: jsonEncode(body)).timeout(_timeout);

  static Future<http.Response> put(String path, Map<String, dynamic> body) =>
      http.put(_uri(path), headers: _jsonHeaders, body: jsonEncode(body)).timeout(_timeout);

  static Future<http.Response> delete(String path) => http.delete(_uri(path)).timeout(_timeout);

  /// Converts the API's standard JSON error response into a safe user message.
  static String errorMessage(http.Response response, {String fallback = 'Something went wrong. Please try again.'}) {
    try {
      final payload = jsonDecode(response.body);
      if (payload is Map && payload['error'] is String && payload['error'].trim().isNotEmpty) {
        return payload['error'] as String;
      }
    } catch (_) {}
    return fallback;
  }
}
