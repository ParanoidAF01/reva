import 'package:reva/services/api_service.dart';

class AadhaarService {
  final ApiService _apiService = ApiService();

  /// Generate OTP for Aadhaar verification
  Future<Map<String, dynamic>> generateOtp(String aadhaarNumber) async {
    try {
      final response = await _apiService.post('/aadhaar/generate-otp', {
        'id_number': aadhaarNumber,
      });
      return response;
    } catch (e) {
      throw Exception('Failed to generate OTP: $e');
    }
  }

  /// Submit OTP for Aadhaar verification
  Future<Map<String, dynamic>> submitOtp(String requestId, String otp) async {
    try {
      final response = await _apiService.post('/aadhaar/submit-otp', {
        'request_id': requestId,
        'otp': otp,
      });
      return response;
    } catch (e) {
      throw Exception('Failed to submit OTP: $e');
    }
  }
}
