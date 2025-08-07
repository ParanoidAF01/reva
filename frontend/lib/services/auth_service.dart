import 'dart:convert';
import 'api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserStorageFields {
  static const String id = 'userId';
  static const String email = 'userEmail';
  static const String mobileNumber = 'userMobileNumber';
  static const String fullName = 'userFullName';
  static const String mpin = 'userMpin';
}

class AuthService {
  // Get current user ID from access token
  Future<String?> getCurrentUserId() async {
    final accessToken = await _getToken('accessToken');
    if (accessToken == null) return null;
    try {
      final parts = accessToken.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final payloadMap = jsonDecode(payload);
      return payloadMap['userId']?.toString();
    } catch (e) {
      return null;
    }
  }

  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Public method to delete token
  Future<void> deleteToken(String key) async {
    await _deleteToken(key);
  }

  // Public getter for token
  Future<String?> getToken(String key) async {
    return await _getToken(key);
  }

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
    required String fullName,
    required String email,
    required String mobileNumber,
    required String mpin,
  }) async {
    final response = await _apiService.post('/auth/register', {
      'fullName': fullName,
      'email': email,
      'mobileNumber': mobileNumber,
      'mpin': mpin,
    });

    // Save tokens if provided
    if (response['data'] != null && response['data']['tokens'] != null) {
      final tokens = response['data']['tokens'];
      if (tokens['accessToken'] != null) {
        await _saveToken('accessToken', tokens['accessToken']);
      }
      if (tokens['refreshToken'] != null) {
        await _saveToken('refreshToken', tokens['refreshToken']);
      }
    }

    // Save user fields in secure storage
    if (response['data'] != null && response['data']['user'] != null) {
      final user = response['data']['user'];
      await _saveUserFields(user);
    }

    return response;
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String mobileNumber,
    required String mpin,
  }) async {
    final response = await _apiService.post('/auth/login', {
      'mobileNumber': mobileNumber,
      'mpin': mpin,
    });

    // Save tokens if provided
    if (response['data'] != null && response['data']['tokens'] != null) {
      final tokens = response['data']['tokens'];
      if (tokens['accessToken'] != null) {
        await _saveToken('accessToken', tokens['accessToken']);
      }
      if (tokens['refreshToken'] != null) {
        await _saveToken('refreshToken', tokens['refreshToken']);
      }
    }

    // Save user fields in secure storage
    if (response['data'] != null && response['data']['user'] != null) {
      final user = response['data']['user'];
      await _saveUserFields(user);
    }

    return response;
  }

  // Send OTP
  Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    return await _apiService.post('/auth/send-otp', {
      'mobileNumber': mobileNumber,
    });
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    return await _apiService.post('/auth/verify-otp', {
      'mobileNumber': mobileNumber,
      'otp': otp,
    });
  }

  // Forgot Password
  Future<Map<String, dynamic>> forgotPassword({
    required String mobileNumber,
    required String newMpin,
  }) async {
    return await _apiService.post('/auth/forgot-password', {
      'mobileNumber': mobileNumber,
      'newMpin': newMpin,
    });
  }

  // Verify MPIN
  Future<Map<String, dynamic>> verifyMpin(String mpin) async {
    final response = await _apiService.post('/auth/verify-mpin', {
      'mpin': mpin,
    });
    // Save user fields in secure storage
    if (response['data'] != null && response['data']['user'] != null) {
      final user = response['data']['user'];
      await _saveUserFields(user);
    }
    return response;
  }

  // Save user fields in secure storage
  Future<void> _saveUserFields(Map<String, dynamic> user) async {
    await _storage.write(key: UserStorageFields.id, value: user['id']?.toString() ?? '');
    await _storage.write(key: UserStorageFields.email, value: user['email'] ?? '');
    await _storage.write(key: UserStorageFields.mobileNumber, value: user['mobileNumber'] ?? '');
    await _storage.write(key: UserStorageFields.fullName, value: user['fullName'] ?? '');
    await _storage.write(key: UserStorageFields.mpin, value: user['mpin'] ?? '');
  }

  // Refresh Token
  Future<Map<String, dynamic>> refreshToken() async {
    final refreshToken = await _getToken('refreshToken');
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final response = await _apiService.post('/auth/refresh-token', {
      'refreshToken': refreshToken,
    });

    // Save new tokens if provided
    if (response['data'] != null && response['data']['tokens'] != null) {
      final tokens = response['data']['tokens'];
      if (tokens['accessToken'] != null) {
        await _saveToken('accessToken', tokens['accessToken']);
      }
      if (tokens['refreshToken'] != null) {
        await _saveToken('refreshToken', tokens['refreshToken']);
      }
    }

    return response;
  }

  // Logout
  Future<Map<String, dynamic>> logout() async {
    final refreshToken = await _getToken('refreshToken');
    final response = await _apiService.post('/auth/logout', {
      'refreshToken': refreshToken,
    });
    await _apiService.clearTokens();
    return response;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final accessToken = await _getToken('accessToken');
    return accessToken != null;
  }
}
