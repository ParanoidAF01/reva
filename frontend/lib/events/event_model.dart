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
      imageUrl: json['imageUrl'] ?? '',
      location: json['location'] ?? '',
      address: json['address'] ?? '',
      startDate: json['startDate'] ?? '',
      startTime: json['startTime'] ?? '',
      attendees: json['attendees'] ?? [],
      seatsLeft: json['seatsLeft'] ?? '',
      price: json['price'] ?? '',
      month: json['month'] ?? '',
      time: json['time'] ?? '',
    );
  }
}
