import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Public method to delete token
  Future<void> deleteToken(String key) async {
    await _deleteToken(key);
  }

  // Public getter for token
  Future<String?> getToken(String key) async {
    return await _getToken(key);
  }

  static const String _baseUrl = 'https://node-reva-2.onrender.com/index/auth';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Store tokens securely
  Future<void> _saveToken(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> _getToken(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> _deleteToken(String key) async {
    await _storage.delete(key: key);
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String mobileNumber,
    required String mpin,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'mobileNumber': mobileNumber,
        'MPIN': mpin,
      }),
    );
    return _processResponse(response);
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String mobileNumber,
    required String mpin,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'mobileNumber': mobileNumber,
        'mpin': mpin,
        'MPIN': mpin,
      }),
    );
    final data = _processResponse(response);
    // Support both 'accessToken' and 'acessToken' (typo from backend)
    final accessToken = data['accessToken'] ?? data['acessToken'];
    if (accessToken != null) {
      await _saveToken('accessToken', accessToken);
    }
    if (data['refreshToken'] != null) {
      await _saveToken('refreshToken', data['refreshToken']);
    }
    return data;
  }

  // Send OTP (Simple API)
  Future<Map<String, dynamic>> sendOtp(String mobileNumber, {String? otp}) async {
    final payload = {
      "Text": "Use * as your User Verification code. This code is Confidential. Never Share it with anyone for your safety. LEXORA",
      "Number": mobileNumber.startsWith('91') ? mobileNumber : '91$mobileNumber',
      "SenderId": "LEXORA",
      "DRNotifyUrl": "https://www.domainname.com/notifyurl",
      "DRNotifyHttpMethod": "POST",
      "Tool": "API"
    };
    final response = await http.post(
      Uri.parse('https://example.com/api/send-otp'), // <-- Replace with your actual endpoint
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );
    return _processResponse(response);
  }

  // Verify OTP (LEXORA API)
  Future<bool> verifyOtp({
    required String mobileNumber,
    required String otp,
    required String sentOtp,
  }) async {
    // Compare the sent OTP with the user input
    return otp == sentOtp;
  }

  // Forgot Password
  Future<Map<String, dynamic>> forgotPassword({
    required String mobileNumber,
    required String newMpin,
  }) async {
    final accessToken = await _getToken('accessToken');
    final response = await http.post(
      Uri.parse('$_baseUrl/forgotPassword'),
      headers: {
        'Content-Type': 'application/json',
        if (accessToken != null) 'x-auth-token': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'mobileNumber': mobileNumber,
        'newMpin': newMpin
      }),
    );
    return _processResponse(response);
  }

  // Logout
  Future<Map<String, dynamic>> logout() async {
    final accessToken = await _getToken('accessToken');
    final response = await http.post(
      Uri.parse('$_baseUrl/logout'),
      headers: {
        'Content-Type': 'application/json',
        if (accessToken != null) 'x-auth-token': 'Bearer $accessToken',
      },
    );
    await _deleteToken('accessToken');
    await _deleteToken('refreshToken');
    return _processResponse(response);
  }

  // Refresh Token
  Future<Map<String, dynamic>> refreshToken() async {
    final refreshToken = await _getToken('refreshToken');
    final response = await http.post(
      Uri.parse('$_baseUrl/refreshtoken'),
      headers: {
        'Content-Type': 'application/json',
        if (refreshToken != null) 'x-auth-token': 'Bearer $refreshToken',
      },
    );
    final data = _processResponse(response);
    if (data['accessToken'] != null) {
      await _saveToken('accessToken', data['accessToken']);
    }
    return data;
  }

  // Helper: Process HTTP response
  Map<String, dynamic> _processResponse(http.Response response) {
    print('RESPONSE STATUS: \\${response.statusCode}');
    print('RESPONSE BODY: \\${response.body}');
    try {
      final Map<String, dynamic> body = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      } else {
        // Support both 'message' and 'msg' fields for error
        final errorMsg = body['message'] ?? body['msg'] ?? 'Unknown error occurred';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Failed to parse response: $e');
    }
  }
}
