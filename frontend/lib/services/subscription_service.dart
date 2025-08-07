import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SubscriptionService {
  Future<Map<String, dynamic>?> getCachedSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('subscription_cache');
    if (cached != null) {
      return Map<String, dynamic>.from(jsonDecode(cached));
    }
  }

  Future<void> cacheSubscription(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('subscription_cache', jsonEncode(data));
  }
  final ApiService _apiService = ApiService();

  // Check subscription status
  Future<Map<String, dynamic>> checkSubscription() async {
    return await _apiService.get('/subscriptions/check');
  }

  // Create subscription
  Future<Map<String, dynamic>> createSubscription(
      Map<String, dynamic> subscriptionData) async {
    return await _apiService.post('/subscriptions/create', subscriptionData);
  }

  // Check subscription status
  // Cancel subscription
  Future<Map<String, dynamic>> cancelSubscription() async {
    return await _apiService.post('/subscriptions/cancel', {});
  }

  // Get subscription history
  Future<Map<String, dynamic>> getSubscriptionHistory() async {
    return await _apiService.get('/subscriptions/history');
  }
}
