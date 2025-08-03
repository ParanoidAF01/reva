import 'auth_service.dart';
import 'profile_service.dart';
import 'posts_service.dart';
import 'events_service.dart';
import 'connections_service.dart';
import 'notifications_service.dart';
import 'subscription_service.dart';
import 'transactions_service.dart';

class ServiceManager {
  static final ServiceManager _instance = ServiceManager._internal();
  factory ServiceManager() => _instance;
  ServiceManager._internal();

  // Services
  final AuthService auth = AuthService();
  final ProfileService profile = ProfileService();
  final PostsService posts = PostsService();
  final EventsService events = EventsService();
  final ConnectionsService connections = ConnectionsService();
  final NotificationsService notifications = NotificationsService();
  final SubscriptionService subscription = SubscriptionService();
  final TransactionsService transactions = TransactionsService();

  // Singleton instance
  static ServiceManager get instance => _instance;
}
