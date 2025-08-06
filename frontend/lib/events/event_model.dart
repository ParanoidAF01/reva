class EventModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String location;
  final String address;
  final String startDate;
  final String startTime;
  final List<dynamic> attendees;
  final int maxAttendees;
  final String seatsLeft;
  final String price;
  final String month;
  final String time;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.address,
    required this.startDate,
    required this.startTime,
    required this.attendees,
    required this.maxAttendees,
    required this.seatsLeft,
    required this.price,
    required this.month,
    required this.time,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image'] ?? '',
      location: json['location'] ?? '',
      address: json['address'] ?? '',
      startDate: json['startDate'] ?? '',
      startTime: json['startTime'] ?? '',
      attendees: json['attendees'] ?? [],
      maxAttendees: json['maxAttendees'] is int ? json['maxAttendees'] : int.tryParse(json['maxAttendees']?.toString() ?? '') ?? 0,
      seatsLeft: json['seatsLeft'] ?? '',
      price: json['price'] ?? json['entryFee']?.toString() ?? '',
      month: json['month'] ?? '',
      time: json['time'] ?? '',
    );
  }
}
