class NotificationModel {
  final String id;
  final String senderId;
  final String senderName;
  final String senderEmail;
  final String recipientId;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderEmail,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      senderId: json['sender'] is Map ? json['sender']['_id'] ?? '' : '',
      senderName: json['sender'] is Map ? json['sender']['fullName'] ?? '' : '',
      senderEmail: json['sender'] is Map ? json['sender']['email'] ?? '' : '',
      recipientId: json['recipient'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
