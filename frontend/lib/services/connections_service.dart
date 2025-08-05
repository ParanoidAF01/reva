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

  // Get pending requests
  Future<Map<String, dynamic>> getPendingRequests() async {
    return await _apiService.get('/connections/pending-requests');
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
