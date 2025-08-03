import 'api_service.dart';

class EventsService {
  final ApiService _apiService = ApiService();

  // Create a new event (admin only)
  Future<Map<String, dynamic>> createEvent(
      Map<String, dynamic> eventData) async {
    return await _apiService.post('/events', eventData);
  }

  // Get all events
  Future<Map<String, dynamic>> getAllEvents() async {
    return await _apiService.get('/events');
  }

  // Get my events (events I'm registered for)
  Future<Map<String, dynamic>> getMyEvents() async {
    return await _apiService.get('/events/me');
  }

  // Get my organized events (admin only)
  Future<Map<String, dynamic>> getMyOrganizedEvents() async {
    return await _apiService.get('/events/organized');
  }

  // Get event by ID
  Future<Map<String, dynamic>> getEventById(String eventId) async {
    return await _apiService.get('/events/$eventId');
  }

  // Update event (admin only)
  Future<Map<String, dynamic>> updateEvent(
      String eventId, Map<String, dynamic> eventData) async {
    return await _apiService.put('/events/$eventId', eventData);
  }

  // Delete event (admin only)
  Future<Map<String, dynamic>> deleteEvent(String eventId) async {
    return await _apiService.delete('/events/$eventId');
  }

  // Register for an event
  Future<Map<String, dynamic>> registerForEvent(String eventId) async {
    return await _apiService.post('/events/$eventId/register', {});
  }

  // Unregister from an event
  Future<Map<String, dynamic>> unregisterFromEvent(String eventId) async {
    return await _apiService.delete('/events/$eventId/register');
  }
}
