class EventModel {
  final String title;
  final String location;
  final String seatsLeft;
  final String price;
  final String description;
  final String imageUrl;
  final String date;
  final String month;
  final String time;

  EventModel({
    required this.title,
    required this.location,
    required this.seatsLeft,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.date,
    required this.month,
    required this.time,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      seatsLeft: json['seatsLeft'] ?? '',
      price: json['price'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      date: json['date'] ?? '',
      month: json['month'] ?? '',
      time: json['time'] ?? '',
    );
  }
}
