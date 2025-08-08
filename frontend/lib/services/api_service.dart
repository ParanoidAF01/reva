import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String _baseUrl = 'https://bdpharmaceutical.com/api/v1';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Get stored token
  Future<String?> _getToken(String key) async {
    return await _storage.read(key: key);
  }

  // Save token
  Future<void> _saveToken(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Delete token
  Future<void> _deleteToken(String key) async {
    await _storage.delete(key: key);
  }

  // Get headers with authentication
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (includeAuth) {
      final accessToken = await _getToken('accessToken');
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    return headers;
  }

  // Make authenticated GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
    );
    return _processResponse(response);
  }

  // Make authenticated POST request
  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final requestBody = jsonEncode(body);

    print('POST REQUEST TO: $_baseUrl$endpoint');
    print('REQUEST HEADERS: $headers');
    print('REQUEST BODY: $requestBody');

    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
      body: requestBody,
    );
    return _processResponse(response);
  }

  // Make authenticated PUT request
  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  // Make authenticated DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
    );
    return _processResponse(response);
  }

  // Make authenticated PATCH request
  Future<Map<String, dynamic>> patch(
      String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  // Process HTTP response
  Map<String, dynamic> _processResponse(http.Response response) {
    print('RESPONSE STATUS: ${response.statusCode}');
    print('RESPONSE BODY: ${response.body}');

    try {
      final dynamic decoded = jsonDecode(response.body);
      final Map<String, dynamic> body = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{'data': decoded};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      } else {
        // Extract meaningful error messages from various API formats
        String? message;
        if (body['message'] is String) message = body['message'];
        if (message == null && body['msg'] is String) message = body['msg'];
        if (message == null && body['error'] is Map &&
            (body['error'] as Map)['message'] is String) {
          message = (body['error'] as Map)['message'] as String;
        }
        if (message == null && body['errors'] is List &&
            (body['errors'] as List).isNotEmpty) {
          final first = (body['errors'] as List).first;
          if (first is String) message = first;
          if (first is Map && first['message'] is String) {
            message = first['message'] as String;
          }
        }

        message ??= 'Unknown error occurred';
        // Do NOT wrap this in the parse catcher below
        throw Exception(message);
      }
    } on FormatException catch (e) {
      // Only catch JSON parsing errors here
      throw Exception('Failed to parse response: $e');
    }
  }

  // Clear all tokens (logout)
  Future<void> clearTokens() async {
    await _deleteToken('accessToken');
    await _deleteToken('refreshToken');
  }
}
