import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/services/api_service.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  EventModel? event;
  bool isLoading = true;
  String? error;
  // Variables for scanned user info (should be set after QR scan)
  String scannedUserName = 'Your Name';
  String scannedUserRole = 'buyer/seller/investor';
  String scannedUserLocation = 'Your City';
  String scannedUserImage = 'assets/dummyprofile.png';

  @override
  void initState() {
    super.initState();
    fetchEventDetail();
  }

  Future<void> fetchEventDetail() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final apiService = ApiService();
      final response = await apiService.get('/events');
      final List<dynamic> eventsData = response['data']['events'] ?? [];
      final found = eventsData.firstWhere(
        (e) => (e['title'] ?? '').toLowerCase().trim() == widget.eventId.toLowerCase().trim(),
        orElse: () => null,
      );
      if (found != null) {
        event = EventModel.fromJson(found);
      } else {
        error = 'Event not found';
      }
    } catch (e) {
      error = e.toString();
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    final width = mediaQuery.size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF22252A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Event', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error ?? 'Error', style: const TextStyle(color: Colors.red)))
              : event == null
                  ? const Center(child: Text('No event found', style: TextStyle(color: Colors.white)))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Event Image
                          if ((event?.imageUrl ?? '').isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(32),
                                bottomRight: Radius.circular(32),
                              ),
                              child: Image.network(
                                event!.imageUrl,
                                width: double.infinity,
                                height: 220,
                                fit: BoxFit.cover,
                              ),
                            ),
                          // Card with event info
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E3339),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(event!.title, style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                                          Text('(${event!.location.isNotEmpty ? event!.location : "-"})', style: GoogleFonts.dmSans(fontSize: 16, color: Colors.white70)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          event!.startDate.isNotEmpty ? _formatDay(event!.startDate) : '-',
                                          style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                                        ),
                                        Text(
                                          event!.month.isNotEmpty ? event!.month : '-',
                                          style: GoogleFonts.dmSans(fontSize: 16, color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(event!.description.isNotEmpty ? event!.description : '-', style: GoogleFonts.dmSans(fontSize: 15, color: Colors.white70)),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0262AB),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    child: const Text('Book this Event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Seats left warning
                          if (event!.seatsLeft != 0)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.yellow, width: 1.2),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.transparent,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Hurry! Only ${event!.seatsLeft} seats left', style: GoogleFonts.dmSans(color: Colors.yellow, fontWeight: FontWeight.w600, fontSize: 16)),
                                ],
                              ),
                            ),
                          const SizedBox(height: 18),
                          // Event Info Row
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(child: _infoCard('Location', event?.location != null && event!.location.isNotEmpty ? event!.location : '-')),
                                const SizedBox(width: 8),
                                Expanded(child: _infoCard('Entry Fee', event?.price != null && event!.price.isNotEmpty ? event!.price : '-')),
                                const SizedBox(width: 8),
                                Expanded(child: _infoCard('Date', event?.startDate != null && event!.startDate.isNotEmpty ? _extractDate(event!.startDate) : '-')),
                                const SizedBox(width: 8),
                                Expanded(child: _infoCard('Time', event?.startTime != null && event!.startTime.isNotEmpty ? _extractTime(event!.startTime) : '-')),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // People coming
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('People comming at this event', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                                Text('See all', style: GoogleFonts.dmSans(color: const Color(0xFF3B9FED), fontWeight: FontWeight.w500, fontSize: 14)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 140,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              children: [
                                // Replace with scanned user's name and info
                                _personCard(scannedUserName, scannedUserRole, scannedUserLocation, scannedUserImage, 'Message'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3339),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _personCard(String name, String role, String location, String imageUrl, String buttonText) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3339),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(role, style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 14)),
                Text(location, style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0262AB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  String _formatDay(String dateStr) {
    try {
      final date = DateTime.tryParse(dateStr);
      if (date != null) {
        return date.day.toString();
      }
    } catch (_) {}
    return '-';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.tryParse(dateStr);
      if (date != null) {
        return '${date.day} ${event!.month}';
      }
    } catch (_) {}
    return dateStr;
  }

  String _extractDate(String dateStr) {
    // Handles ISO format: yyyy-MM-ddTHH:mm:ss.sssZ
    try {
      final date = DateTime.tryParse(dateStr);
      if (date != null) {
        const monthNames = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];
        final day = date.day.toString().padLeft(2, '0');
        final month = monthNames[date.month - 1];
        final year = date.year.toString();
        return '$day $month $year';
      }
    } catch (_) {}
    return dateStr;
  }

  String _extractTime(String dateStr) {
    // Handles ISO format: yyyy-MM-ddTHH:mm:ss.sssZ
    try {
      final date = DateTime.tryParse(dateStr);
      if (date != null) {
        final hour = date.hour.toString().padLeft(2, '0');
        final minute = date.minute.toString().padLeft(2, '0');
        return '$hour:$minute';
      }
    } catch (_) {}
    return '-';
  }
}

class EventModel {
  final String title;
  final String location;
  final String startDate;
  final String startTime;
  final String price;
  final int seatsLeft;
  final String description;
  final String imageUrl;

  EventModel({
    required this.title,
    required this.location,
    required this.startDate,
    required this.startTime,
    required this.price,
    required this.seatsLeft,
    required this.description,
    required this.imageUrl,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      title: (json['title'] ?? '') as String,
      location: (json['location'] ?? '') as String,
      startDate: (json['startDate'] ?? '')?.toString() ?? '',
      startTime: (json['startTime'] ?? '')?.toString() ?? '',
      price: (json['entryFee'] ?? '')?.toString() ?? '',
      seatsLeft: json['maxAttendees'] ?? 0,
      description: (json['description'] ?? '') as String,
      imageUrl: (json['image'] ?? '') as String,
    );
  }

  String get month {
    // Try to parse the startDate and extract the month name
    try {
      final parsedDate = DateTime.tryParse(startDate);
      if (parsedDate != null) {
        const monthNames = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];
        return monthNames[parsedDate.month - 1];
      }
    } catch (_) {}
    return '';
  }
}
