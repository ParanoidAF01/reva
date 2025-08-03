class NotificationModel {
  final String userName;
  final String timeAgo;
  final String title;
  final String message;
  final String avatarUrl;
  final String statusIconUrl;

  NotificationModel({
    required this.userName,
    required this.timeAgo,
    required this.title,
    required this.message,
    required this.avatarUrl,
    required this.statusIconUrl,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      userName: json['userName'] ?? '',
      timeAgo: json['timeAgo'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      statusIconUrl: json['statusIconUrl'] ?? '',
    );
  }
}
