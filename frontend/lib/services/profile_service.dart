import 'api_service.dart';

class ProfileService {
  final ApiService _apiService = ApiService();

  // Get my profile
  Future<Map<String, dynamic>> getMyProfile() async {
    return await _apiService.get('/profiles/me');
  }

  // Get profile by user ID
  Future<Map<String, dynamic>> getProfileById(String userId) async {
    return await _apiService.get('/profiles/$userId');
  }

  // Update my profile
  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> profileData) async {
    return await _apiService.put('/profiles', profileData);
  }

  // Get all profiles (admin only)
  Future<Map<String, dynamic>> getAllProfiles() async {
    return await _apiService.get('/profiles/all');
  }
}
