import 'package:flutter/material.dart';
import '../services/service_manager.dart';

class UserProvider extends ChangeNotifier {
  static String? userPhoneNumber;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  bool _isSubscribed = false;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isSubscribed => _isSubscribed;
  String get userName =>
      _userData?['user']?['fullName'] ?? _userData?['fullName'] ?? 'User';

  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ServiceManager.instance.profile.getMyProfile();
      if (response['success'] == true && response['data'] != null) {
        _userData = response['data'];
        // Save phone number for QR
        userPhoneNumber = _userData?['user']?['mobileNumber'];
        // Fetch connections from backend and update userData
        final connectionsResponse =
            await ServiceManager.instance.connections.getMyConnections();
        if (connectionsResponse['success'] == true &&
            connectionsResponse['data'] != null) {
          _userData!['connections'] =
              connectionsResponse['data']['connections'] ?? [];
        }

        // Fetch pending requests (incoming)
        final pendingRequestsResponse =
            await ServiceManager.instance.connections.getPendingRequests();
        if (pendingRequestsResponse['success'] == true &&
            pendingRequestsResponse['data'] != null) {
          _userData!['pendingRequests'] =
              pendingRequestsResponse['data']['totalPendingRequests'] ?? 0;
        }

        // Fetch sent requests (outgoing)
        final sentRequestsResponse =
            await ServiceManager.instance.connections.getSentRequests();
        if (sentRequestsResponse['success'] == true &&
            sentRequestsResponse['data'] != null) {
          _userData!['pendingConnects'] =
              sentRequestsResponse['data']['totalSentRequests'] ?? 0;
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkSubscription() async {
    try {
      final response =
          await ServiceManager.instance.subscription.checkSubscription();
      if (response['success'] == true) {
        _isSubscribed = response['data']['isSubscribed'] ?? false;
      }
    } catch (e) {
      print('Error checking subscription: $e');
      _isSubscribed = false;
    }
    notifyListeners();
  }

  void clearUserData() {
    _userData = null;
    _isSubscribed = false;
    notifyListeners();
  }

  void updateUserData(Map<String, dynamic> userData) {
    _userData = userData;
    notifyListeners();
  }

  Future<void> refreshConnectionCounts() async {
    try {
      // Fetch pending requests (incoming)
      final pendingRequestsResponse =
          await ServiceManager.instance.connections.getPendingRequests();
      print('PENDING REQUESTS RESPONSE:');
      print('Response: $pendingRequestsResponse');

      if (pendingRequestsResponse['success'] == true &&
          pendingRequestsResponse['data'] != null) {
        _userData!['pendingRequests'] =
            pendingRequestsResponse['data']['totalPendingRequests'] ?? 0;
        print('Total pending requests: ${_userData!['pendingRequests']}');
      }

      // Fetch sent requests (outgoing)
      final sentRequestsResponse =
          await ServiceManager.instance.connections.getSentRequests();
      print('SENT REQUESTS RESPONSE:');
      print('Response: $sentRequestsResponse');

      if (sentRequestsResponse['success'] == true &&
          sentRequestsResponse['data'] != null) {
        _userData!['pendingConnects'] =
            sentRequestsResponse['data']['totalSentRequests'] ?? 0;
        print('Total sent requests: ${_userData!['pendingConnects']}');
      }

      notifyListeners();
    } catch (e) {
      print('Error refreshing connection counts: $e');
    }
  }

  // Get pending requests data for display
  Future<List<dynamic>> getPendingRequestsData() async {
    try {
      final response =
          await ServiceManager.instance.connections.getPendingRequests();
      if (response['success'] == true && response['data'] != null) {
        return response['data']['pendingRequests'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error fetching pending requests data: $e');
      return [];
    }
  }

  // Get sent requests data for display
  Future<List<dynamic>> getSentRequestsData() async {
    try {
      final response =
          await ServiceManager.instance.connections.getSentRequests();
      if (response['success'] == true && response['data'] != null) {
        return response['data']['sentRequests'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error fetching sent requests data: $e');
      return [];
    }
  }
}
