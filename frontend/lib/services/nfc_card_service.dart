import 'api_service.dart';

class NfcCardService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> requestNfcCard(Map<String, dynamic> data) async {
    return await _apiService.post('/nfc-cards/request', data);
  }

  Future<Map<String, dynamic>> getMyStatus() async {
    return await _apiService.get('/nfc-cards/my-status');
  }
}
