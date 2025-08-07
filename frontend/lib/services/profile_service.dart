import 'api_service.dart';

class ProfileService {
  final ApiService _apiService = ApiService();

  // Get my profile
  Future<Map<String, dynamic>> getMyProfile() async {
    try {
      return await _apiService.get('/profiles/me');
    } catch (e) {
      throw Exception(_filterError(e));
    }
  }

  // Get profile by user ID
  Future<Map<String, dynamic>> getProfileById(String userId) async {
    try {
      return await _apiService.get('/profiles/$userId');
    } catch (e) {
      throw Exception(_filterError(e));
    }
  }

  // Update my profile
  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> profileData) async {
    try {
      return await _apiService.put('/profiles', profileData);
    } catch (e) {
      throw Exception(_filterError(e));
    }
  }

  // Get all profiles (admin only)
  Future<Map<String, dynamic>> getAllProfiles() async {
    try {
      return await _apiService.get('/profiles/all');
    } catch (e) {
      throw Exception(_filterError(e));
    }
  }

  String _filterError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('Failed host lookup')) {
      return 'Network error: Please check your internet connection.';
    }
    if (msg.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (msg.contains('401')) {
      return 'Session expired. Please log in again.';
    }
    // Add more filters as needed
    return msg.replaceAll('Exception:', '').trim();
  }
}
