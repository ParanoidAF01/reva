import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  // Store connection status for each attendee
  Map<String, bool> attendeeConnectionStatus = {};

  // Fetch connection status for all attendees
  Future<void> fetchAttendeeConnections(List attendees) async {
    final apiService = ApiService();
    Map<String, bool> statusMap = {};
    for (var attendee in attendees) {
      try {
        // Replace with your actual endpoint and logic
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

  EventModel? event;
  bool isLoading = true;
  String? error;
  bool isBooked = false; // Track booking status
  // Variables for scanned user info (should be set after QR scan)
  String scannedUserName = 'Your Name';
  String scannedUserRole = 'buyer/seller/investor';
  String scannedUserLocation = 'Your City';
  String scannedUserImage = 'assets/dummyprofile.png';

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
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

      debugPrint('Available events: ${eventsData.map((e) => e['title']).toList()}');
      debugPrint('Looking for event: ${widget.eventId}');

      final found = eventsData.firstWhere(
        (e) {
          final eventTitle = (e['title'] ?? '').toString().toLowerCase().trim();
          final searchTitle = widget.eventId.toLowerCase().trim();
          debugPrint('Comparing: "$eventTitle" with "$searchTitle"');
          return eventTitle == searchTitle;
        },
        orElse: () => null,
      );

      if (found != null) {
        event = EventModel.fromJson(found);
        debugPrint('Found event: ${event?.title}');

        // Check if user has already booked this event
        final eventsService = EventsService();
        final myEventsResponse = await eventsService.getMyEvents();
        final List<dynamic> myEvents = myEventsResponse['data']['events'] ?? [];
        final booked = myEvents.any((e) {
          // Compare by event id or title
          if (e['id'] != null && event?.id != null) {
            return e['id'].toString() == event!.id.toString();
          }
          // fallback to title if id not present
          return (e['title'] ?? '').toString().toLowerCase().trim() == (event?.title ?? '').toLowerCase().trim();
        });
        setState(() {
          isBooked = booked;
        });

        // Fetch attendee connection status
        if (event?.attendees != null && event!.attendees.isNotEmpty) {
          await fetchAttendeeConnections(event!.attendees);
        }
      } else {
        error = 'Event not found: ${widget.eventId}';
        debugPrint('Event not found in list');
      }
    } catch (e) {
      error = e.toString();
      debugPrint('Error fetching event: $e');
    }
    setState(() {
      isLoading = false;
    });
  }

  late Razorpay _razorpay;

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
                                    onPressed: isBooked ? null : _openCheckout,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isBooked ? Colors.grey : const Color(0xFF0262AB),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    child: Text(
                                      isBooked ? 'Already Booked' : 'Book this Event',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Seats left warning
                          if ((event?.seatsLeft ?? 0) != 0)
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
                                  Text('Hurry! Only ${event?.seatsLeft ?? 0} seats left', style: GoogleFonts.dmSans(color: Colors.yellow, fontWeight: FontWeight.w600, fontSize: 16)),
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
                                Expanded(child: _dateCard(event)),
                                const SizedBox(width: 8),
                                Expanded(child: _infoCard('Time', event?.startTime != null && event!.startTime.isNotEmpty ? _extractTime(event!.startTime) : '-')),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // People coming
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E3339),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text('People coming at this event', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                                    ),
                                    Text('${(event?.attendees ?? []).length} attendees', style: GoogleFonts.dmSans(color: const Color(0xFF3B9FED), fontWeight: FontWeight.w500, fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if ((event?.attendees ?? []).isNotEmpty)
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: 230,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: (event?.attendees ?? []).length,
                                          itemBuilder: (context, index) {
                                            final attendee = (event?.attendees ?? [])[index];
                                            final isConnected = attendeeConnectionStatus[attendee.id.toString()] ?? false;
                                            return _personCard(
                                              attendee.fullName,
                                              'Attendee',
                                              'Registered',
                                              'assets/dummyprofile.png',
                                              isConnected ? 'Message' : 'Connect',
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E2126),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white10,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          color: Colors.white54,
                                          size: 32,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'No attendees yet',
                                          style: GoogleFonts.dmSans(
                                            color: Colors.white70,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Be the first to register!',
                                          style: GoogleFonts.dmSans(
                                            color: Colors.white54,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3339),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _dateCard(EventModel? event) {
    String day = '-';
    String month = '-';
    if (event != null && event.startDate.isNotEmpty) {
      final date = DateTime.tryParse(event.startDate);
      if (date != null) {
        day = date.day.toString().padLeft(2, '0');
        month = _monthName(date.month);
      }
    }
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3339),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Date', style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(day, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(width: 6),
              Text(month, style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month];
  }

  Widget _personCard(String name, String role, String location, String imageUrl, String buttonText) {
    return Container(
      width: 180,
      height: 270,
      margin: const EdgeInsets.only(right: 18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF23262B),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.asset(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              // Lock icon for private profile (optional, add logic if needed)
              // Positioned(
              //   right: 0,
              //   top: 0,
              //   child: Icon(Icons.lock, color: Colors.white70, size: 18),
              // ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name.isNotEmpty ? name : 'Unknown',
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            role,
            style: GoogleFonts.dmSans(
              color: Colors.white70,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Container(),
              ),
              Text(
                location,
                style: GoogleFonts.dmSans(
                  color: Colors.white38,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.right,
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonText == 'Message' ? Colors.white : const Color(0xFF0262AB),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                minimumSize: const Size(0, 38),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: buttonText == 'Message' ? const Color(0xFF0262AB) : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // Log the endpoint being hit
      debugPrint('Hitting endpoint: POST /events/${event!.id}/register');

      // Register for the event
      final eventsService = EventsService();
      await eventsService.registerForEvent(event!.id);

      // TODO: Refresh event data to get updated attendees list
      // TODO: Open Razorpay payment gateway if needed
      // _razorpay.open(options); // Uncomment and define 'options' if needed
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Payment initialization failed: ' + e.toString()),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Payment failed: ${response.message ?? 'Unknown error'}'),
      backgroundColor: Colors.red,
    ));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('External wallet selected: ${response.walletName}'),
    ));
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_QyOoTjd4T2z2Nj',
      'amount': int.parse(event?.price ?? '0') * 100, // Convert to paise
      'name': event?.title ?? 'Event',
      'description': event?.description ?? '',
      'prefill': {
        'contact': '',
        'email': ''
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
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
      attendees = (json['attendees'] as List).where((attendee) => attendee != null).map((attendee) => AttendeeModel.fromJson(attendee)).toList();
    }

    return EventModel(
      id: (json['_id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      location: (json['location'] ?? '') as String,
      startDate: (json['startDate'] ?? '')?.toString() ?? '',
      startTime: (json['startTime'] ?? '')?.toString() ?? '',
      price: (json['entryFee'] ?? '')?.toString() ?? '',
      seatsLeft: json['maxAttendees'] ?? 0,
      description: (json['description'] ?? '') as String,
      imageUrl: (json['image'] ?? '') as String,
      attendees: attendees,
    );
  }

  // Check if current user is already registered
  bool isUserRegistered(String userId) {
    return attendees.any((attendee) => attendee.id == userId);
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
      id: (json['_id'] ?? '') as String,
      fullName: (json['fullName'] ?? 'Unknown') as String,
      email: (json['email'] ?? '') as String,
    );
  }
}
