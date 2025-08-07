import 'api_service.dart';

class NotificationsService {
  final ApiService _apiService = ApiService();


  // Get my notifications
  Future<Map<String, dynamic>> getMyNotifications() async {
    try {
      return await _apiService.get('/notifications/me');
    } catch (e) {
      throw Exception(_filterError(e));
    }
  }

  // Get notification stats
  Future<Map<String, dynamic>> getNotificationStats() async {
    try {
      return await _apiService.get('/notifications/stats');
    } catch (e) {
      throw Exception(_filterError(e));
    }
  }

  // Get notification by ID
  Future<Map<String, dynamic>> getNotificationById(String notificationId) async {
    try {
      return await _apiService.get('/notifications/$notificationId');
    } catch (e) {
      throw Exception(_filterError(e));
    }
  }

  // Mark notification as read
  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    try {
      return await _apiService.patch('/notifications/$notificationId/read', {});
    } catch (e) {
      throw Exception(_filterError(e));
    }
  }

  // Mark all notifications as read
  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      return await _apiService.patch('/notifications/mark-all-read', {});
    } catch (e) {
      throw Exception(_filterError(e));
    }
  }

  // Delete notification
  Future<Map<String, dynamic>> deleteNotification(String notificationId) async {
    try {
      return await _apiService.delete('/notifications/$notificationId');
    } catch (e) {
      throw Exception(_filterError(e));
    }
  }

  String _filterError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('Failed host lookup')) {
      return 'Network error: Please check your internet connection.';
    }
    if (msg.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (msg.contains('401')) {
      return 'Session expired. Please log in again.';
    }
    // Add more filters as needed
    return msg.replaceAll('Exception:', '').trim();
  }

  // Delete all notifications
  Future<Map<String, dynamic>> deleteAllNotifications() async {
    return await _apiService.delete('/notifications/delete-all');
  }

  // Create notification (admin only)
  Future<Map<String, dynamic>> createNotification(
      Map<String, dynamic> notificationData) async {
    return await _apiService.post('/notifications/create', notificationData);
  }
  // Get my notifications

  // Send system notification (admin only)
  Future<Map<String, dynamic>> sendSystemNotification(
      Map<String, dynamic> notificationData) async {
    return await _apiService.post('/notifications/system', notificationData);
  }

  // Send event notification (admin only)
  Future<Map<String, dynamic>> sendEventNotification(
      Map<String, dynamic> notificationData) async {
    return await _apiService.post('/notifications/event', notificationData);
  }
}
