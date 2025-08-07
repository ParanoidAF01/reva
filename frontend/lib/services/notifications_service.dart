import 'api_service.dart';

class NotificationsService {
  final ApiService _apiService = ApiService();

  // Get my notifications
  Future<Map<String, dynamic>> getMyNotifications() async {
    return await _apiService.get('/notifications/me');
  }

  // Get notification stats
  Future<Map<String, dynamic>> getNotificationStats() async {
    return await _apiService.get('/notifications/stats');
  }

  // Get notification by ID
  Future<Map<String, dynamic>> getNotificationById(
      String notificationId) async {
    return await _apiService.get('/notifications/$notificationId');
  }

  // Mark notification as read
  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    return await _apiService.patch('/notifications/$notificationId/read', {});
  }

  // Mark all notifications as read
  Future<Map<String, dynamic>> markAllAsRead() async {
    return await _apiService.patch('/notifications/mark-all-read', {});
  }

  // Delete notification
  Future<Map<String, dynamic>> deleteNotification(String notificationId) async {
    return await _apiService.delete('/notifications/$notificationId');
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
