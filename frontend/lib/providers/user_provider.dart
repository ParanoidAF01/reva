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
}
