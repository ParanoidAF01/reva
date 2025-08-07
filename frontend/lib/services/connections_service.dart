import 'api_service.dart';

class ConnectionsService {
  // Cancel outgoing connection request
  Future<Map<String, dynamic>> cancelConnectionRequest(String requestId) async {
    return await _apiService.put('/connections/request/$requestId/cancel', {});
  }

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
  Future<Map<String, dynamic>> getConnectionSuggestions({int page = 1, int limit = 50}) async {
    return await _apiService.get('/connections/suggestions?page=$page&limit=$limit');
  }

  // Get pending requests (incoming)
  Future<Map<String, dynamic>> getPendingRequests() async {
    return await _apiService.get('/connections/pending-requests');
  }

  // Get sent requests (outgoing)
  Future<Map<String, dynamic>> getSentRequests() async {
    return await _apiService.get('/connections/sent-requests');
  }

  // Reject connection request
  Future<Map<String, dynamic>> rejectConnectionRequest(String requestId) async {
    return await _apiService.put('/connections/request/$requestId/respond', {
      'action': 'reject',
    });
  }

  // Send connection request
  Future<Map<String, dynamic>> sendConnectionRequest(String toUserId) async {
    print('SENDING CONNECTION REQUEST:');
    print('toUserId: $toUserId');

    return await _apiService.post('/connections/request', {
      'toUserId': toUserId,
    });
  }

  // Remove connection
  Future<Map<String, dynamic>> removeConnection(String connectionId) async {
    return await _apiService.delete('/connections/$connectionId');
  }
}
