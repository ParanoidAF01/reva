import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/profile/event_user_profile_screen.dart';
import 'package:reva/services/api_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:reva/services/events_service.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Map<String, bool> attendeeConnectionStatus = {};
  EventModel? event;
  bool isLoading = true;
  String? error;
  bool isBooked = false;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handlePaymentExternalWallet);
    fetchEventDetail();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
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
      var foundData = eventsData.firstWhere((e) => (e['_id'] ?? '').toString() == widget.eventId.toString(), orElse: () => null);
      if (foundData == null) {
        foundData = eventsData.firstWhere((e) => (e['title'] ?? '').toString().toLowerCase().trim() == widget.eventId.toLowerCase().trim(), orElse: () => null);
      }
      if (foundData != null) {
        event = EventModel.fromJson(foundData);
        final eventsService = EventsService();
        final myEventsResponse = await eventsService.getMyEvents();
        final List<dynamic> myEvents = myEventsResponse['data']['events'] ?? [];
        final booked = myEvents.any((e) =>
            (e['id'] != null && event != null && e['id'].toString() == event!.id.toString()) ||
            (e['title'] ?? '').toString().toLowerCase().trim() == (event?.title ?? '').toLowerCase().trim());
        setState(() {
          isBooked = booked;
        });
        if (event!.attendees.isNotEmpty) {
          await fetchAttendeeConnections(event!.attendees);
        }
      } else {
        setState(() {
          error = 'Event not found: ${widget.eventId}';
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchAttendeeConnections(List attendees) async {
    final apiService = ApiService();
    Map<String, bool> statusMap = {};
    for (var attendee in attendees) {
      try {
        final res = await apiService.get('/connections/check?userId=' + attendee.id.toString());
        statusMap[attendee.id.toString()] = res['data']?['connected'] == true;
      } catch (_) {
        statusMap[attendee.id.toString()] = false;
      }
    }
    setState(() {
      attendeeConnectionStatus = statusMap;
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final eventsService = EventsService();
      await eventsService.registerForEvent(event!.id);
      await fetchEventDetail();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during registration: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message ?? 'Unknown error'}'), backgroundColor: Colors.red),
    );
  }

  void _handlePaymentExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet Selected: ${response.walletName}')),
    );
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_QyOoTjd4T2z2Nj',
      'amount': (int.tryParse(event?.price ?? '0') ?? 0) * 100,
      'name': event?.title ?? '',
      'description': event?.description ?? '',
      'prefill': {
        'contact': '',
        'email': ''
      },
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  String _formatDateDay(String dateStr) {
    try {
      final date = DateTime.tryParse(dateStr);
      if (date != null) return date.day.toString().padLeft(2, '0');
    } catch (_) {}
    return '-';
  }

  String _formatDateMonth(String dateStr) {
    try {
      final date = DateTime.tryParse(dateStr);
      if (date != null) {
        const months = [
          '',
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return months[date.month];
      }
    } catch (_) {}
    return '-';
  }

  String _extractTime(String dateStr) {
    try {
      final date = DateTime.tryParse(dateStr);
      if (date != null) {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
    } catch (_) {}
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    final seatsLeft = event != null ? (event!.seatsLeft - event!.attendees.length) : 0;

    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF222222),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF222222),
        body: Center(child: Text(error!, style: const TextStyle(color: Colors.red))),
      );
    }

    if (event == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF222222),
        body: const Center(child: Text('Event not found', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      appBar: AppBar(
        backgroundColor: const Color(0xFF222222),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
        title: Text(event!.title, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP COVER IMAGE
            if (event!.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
                child: Image.network(event!.imageUrl, width: double.infinity, height: 220, fit: BoxFit.cover),
              ),
            // White card floating section - styled like your image.jpg
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2E3339),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.13),
                    blurRadius: 18,
                    offset: const Offset(0, 3),
                  ),
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row: title/location (left), day/month (right)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event!.title,
                              style: GoogleFonts.dmSans(
                                fontSize: 22, color: Colors.white,
                                fontWeight: FontWeight.bold)),
                            Text('(${event!.location.isNotEmpty ? event!.location : "-"})',
                              style: GoogleFonts.dmSans(fontSize: 14, color: Colors.white70)),
                          ],
                        )
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            event!.startDate.isNotEmpty ? _formatDateDay(event!.startDate) : '-',
                            style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          Text(
                            event!.startDate.isNotEmpty ? _formatDateMonth(event!.startDate) : '-',
                            style: GoogleFonts.dmSans(fontSize: 16, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Description
                  Text(event!.description.isNotEmpty ? event!.description : '-',
                      style: GoogleFonts.dmSans(fontSize: 15, color: Colors.white70)),
                  const SizedBox(height: 16),
                  // Book button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isBooked ? null : _openCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isBooked ? Colors.grey : const Color(0xFF0262AB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        isBooked ? 'Already Booked' : 'Book this Event',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                  ),
                  if (seatsLeft > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 18),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.yellow, width: 1.2),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.transparent,
                      ),
                      child: Center(
                        child: Text('Hurry! Only $seatsLeft seats left',
                            style: GoogleFonts.dmSans(
                                color: Colors.yellow,
                                fontWeight: FontWeight.w600,
                                fontSize: 16)),
                      ),
                    ),
                ],
              ),
            ),
            // FOUR INFO CARDS ROW
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal:4),
                    child: _infoCard('Location', event!.location),
                  )),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal:4),
                    child: _infoCard('Entry Fee', event!.price),
                  )),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal:4),
                    child: _dateCard(event!),
                  )),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal:4),
                    child: _infoCard('Time', _extractTime(event!.startTime)),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // "People coming at this event" Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2E3339),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('People coming at this event',
                        style: GoogleFonts.dmSans(
                          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                      Text('${event!.attendees.length} attendees',
                        style: GoogleFonts.dmSans(
                          color: const Color(0xFF3B9FED), fontWeight: FontWeight.w500, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  event!.attendees.isNotEmpty
                    ? SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: event!.attendees.length,
                          itemBuilder: (context, index) {
                            final attendee = event!.attendees[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Container(
                                width: 120,
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    image: AssetImage('assets/peopleyoumayknowtile_background.png'),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 10),
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundImage: const AssetImage('assets/dummyprofile.png'),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(attendee.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 3),
                                    const Text('Attendee', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                    const Text('Registered', style: TextStyle(color: Colors.white38, fontSize: 9)),
                                    const SizedBox(height: 7),
                                    SizedBox(
                                      width: 80,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => EventUserProfileScreen(
                                                userInfo: {
                                                  'id': attendee.id,
                                                  'fullName': attendee.fullName,
                                                  'email': attendee.email,
                                                  'phone': '***********',
                                                  'role': 'Attendee',
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF0262AB),
                                          shape: const StadiumBorder(),
                                          padding: const EdgeInsets.symmetric(vertical: 6),
                                        ),
                                        child: const Text('Connect', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2126),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10, width: 1),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.people_outline, color: Colors.white54, size: 32),
                            const SizedBox(height: 8),
                            Text('No attendees yet', style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text('Be the first to register!', style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 32)
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3339),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _dateCard(EventModel event) {
    final day = _formatDateDay(event.startDate);
    final month = _formatDateMonth(event.startDate);
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3339),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Date', style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(day,
                style: GoogleFonts.dmSans(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(month,
                  style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13),
                  maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// -- Models for event/attendees --

class EventModel {
  final String id;
  final String title;
  final String location;
  final String startDate;
  final String startTime;
  final String price;
  final int seatsLeft;
  final String description;
  final String imageUrl;
  final List<AttendeeModel> attendees;

  EventModel({
    required this.id,
    required this.title,
    required this.location,
    required this.startDate,
    required this.startTime,
    required this.price,
    required this.seatsLeft,
    required this.description,
    required this.imageUrl,
    required this.attendees,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    List<AttendeeModel> attendees = [];
    if (json['attendees'] != null && json['attendees'] is List) {
      attendees = (json['attendees'] as List)
          .where((e) => e != null)
          .map((e) => AttendeeModel.fromJson(e))
          .toList();
    }
    return EventModel(
      id: (json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      startDate: (json['startDate'] ?? '').toString(),
      startTime: (json['startTime'] ?? '').toString(),
      price: (json['entryFee'] ?? '0').toString(),
      seatsLeft: json['maxAttendees'] is String
          ? int.tryParse(json['maxAttendees']) ?? 0
          : json['maxAttendees'] ?? 0,
      description: (json['description'] ?? '').toString(),
      imageUrl: (json['image'] ?? '').toString(),
      attendees: attendees,
    );
  }
}

class AttendeeModel {
  final String id;
  final String fullName;
  final String email;

  AttendeeModel({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory AttendeeModel.fromJson(Map<String, dynamic> json) {
    return AttendeeModel(
      id: (json['_id'] ?? '').toString(),
      fullName: (json['fullName'] ?? 'Unknown').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }
}
