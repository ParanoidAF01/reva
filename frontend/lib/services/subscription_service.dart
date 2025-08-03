import 'api_service.dart';

class SubscriptionService {
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

  // Cancel subscription
  Future<Map<String, dynamic>> cancelSubscription() async {
    return await _apiService.post('/subscriptions/cancel', {});
  }

  // Get subscription history
  Future<Map<String, dynamic>> getSubscriptionHistory() async {
    return await _apiService.get('/subscriptions/history');
  }
}
