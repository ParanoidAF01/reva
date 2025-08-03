import 'api_service.dart';

class ConnectionsService {
  final ApiService _apiService = ApiService();

  // Connect via QR code
  Future<Map<String, dynamic>> connectViaQR(Map<String, dynamic> qrData) async {
    final mobileNumber = qrData['mobileNumber'];
    return await _apiService.get('/connections/qr?mobileNumber=$mobileNumber');
  }

  // Get my connections
  Future<Map<String, dynamic>> getMyConnections() async {
    return await _apiService.get('/connections');
  }

  // Get connection count
  Future<Map<String, dynamic>> getConnectionCount() async {
    return await _apiService.get('/connections/count');
  }

  // Get connection suggestions
  Future<Map<String, dynamic>> getConnectionSuggestions() async {
    return await _apiService.get('/connections/suggestions');
  }

  // Remove connection
  Future<Map<String, dynamic>> removeConnection(String connectionId) async {
    return await _apiService.delete('/connections/$connectionId');
  }
}
