import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  static const String baseUrl = AppConstants.baseUrl;

  static Future<dynamic> get(String endpoint, {String? token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(token),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> post(
      String endpoint,
      Map<String, dynamic> body, {
        String? token,
      }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(token),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> put(
      String endpoint,
      Map<String, dynamic> body, {
        String? token,
      }) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(token),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  static Map<String, String> _headers(String? token) {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      throw Exception('API error: ${response.statusCode}');
    }
  }
}