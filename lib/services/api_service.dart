import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../utils/constants.dart';

class ApiService {
  static const String baseUrl = AppConstants.baseUrl;

  static Future<dynamic> get(String endpoint, {String? token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _jsonHeaders(token),
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
      headers: _jsonHeaders(token),
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
      headers: _jsonHeaders(token),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> postMultipart(
      String endpoint, {
        required Map<String, String> fields,
        required String fileFieldName,
        required List<int> fileBytes,
        required String fileName,
        String? token,
      }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$endpoint'),
    );

    request.headers.addAll(_authHeaders(token));
    request.fields.addAll(fields);

    request.files.add(
      http.MultipartFile.fromBytes(
        fileFieldName,
        fileBytes,
        filename: fileName,
        contentType: _getImageMediaType(fileName),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  }

  static Map<String, String> _jsonHeaders(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Map<String, String> _authHeaders(String? token) {
    final headers = <String, String>{};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static MediaType _getImageMediaType(String fileName) {
    final lowerFileName = fileName.toLowerCase();

    if (lowerFileName.endsWith('.png')) {
      return MediaType('image', 'png');
    }

    if (lowerFileName.endsWith('.webp')) {
      return MediaType('image', 'webp');
    }

    return MediaType('image', 'jpeg');
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }

      return jsonDecode(response.body);
    }

    throw Exception(_extractErrorMessage(response));
  }

  static String _extractErrorMessage(http.Response response) {
    if (response.body.isEmpty) {
      return 'API error: ${response.statusCode}';
    }

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is String && decoded.trim().isNotEmpty) {
        return decoded;
      }

      if (decoded is Map<String, dynamic>) {
        final message =
            decoded['message'] ?? decoded['title'] ?? decoded['error'];

        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString();
        }

        final errors = decoded['errors'];

        if (errors is Map) {
          final messages = <String>[];

          for (final value in errors.values) {
            if (value is List) {
              messages.addAll(value.map((item) => item.toString()));
            } else {
              messages.add(value.toString());
            }
          }

          if (messages.isNotEmpty) {
            return messages.join('\n');
          }
        }
      }
    } catch (_) {
      return response.body;
    }

    return 'API error: ${response.statusCode}';
  }
}