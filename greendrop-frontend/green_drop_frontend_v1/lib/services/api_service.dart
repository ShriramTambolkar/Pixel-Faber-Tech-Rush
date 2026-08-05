import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  static Future<http.Response> post(String path, Map<String, dynamic> body) {
    return http.post(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> get(String path) {
    return http.get(Uri.parse('$baseUrl$path'));
  }

  static Future<http.Response> patch(String path, Map<String, dynamic> body) {
    return http.patch(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String path) {
    return http.delete(Uri.parse('$baseUrl$path'));
  }
}
