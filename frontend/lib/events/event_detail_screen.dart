import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/events/event_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
      // Replace with your actual API endpoint
      final response = await http.get(Uri.parse('https://example.com/api/events/${widget.eventId}'));
      if (response.statusCode == 200) {
        event = EventModel.fromJson(jsonDecode(response.body));
      } else {
        error = 'Failed to load event details';
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : event == null
                  ? const Center(child: Text('No event found', style: TextStyle(color: Colors.white)))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: height * 0.04),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () => Navigator.of(context).pop(),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF23262B),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "Event",
                                  style: GoogleFonts.dmSans(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(flex: 2),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Event Image
                          if (event!.imageUrl.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.network(
                                  event!.imageUrl,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          const SizedBox(height: 18),
                          // Event Card
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E3339),
                                borderRadius: BorderRadius.circular(28),
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
                                            Text(
                                              event!.title,
                                              style: GoogleFonts.dmSans(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '(${event!.location})',
                                              style: GoogleFonts.dmSans(
                                                fontSize: 14,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            event!.date,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            event!.month,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 14,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    event!.description,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Book Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0262AB),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                      child: const Text('Book this Event', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Seats left warning
                          if (event!.seatsLeft.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.yellow, width: 1.2),
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('🔥 ', style: TextStyle(fontSize: 18)),
                                    Text(
                                      'Hurry! Only ${event!.seatsLeft} seats left',
                                      style: GoogleFonts.dmSans(
                                        color: Colors.yellow,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 18),
                          // Event Info Row
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _infoCard('Location', event!.location),
                                _infoCard('Entry Fee', event!.price),
                                _infoCard('Date', event!.date),
                                _infoCard('Time', event!.time),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // People coming (mocked for now)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.06),
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
                              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                              children: [
                                _personCard('Piyush Patyal', 'buyer/seller/investor', 'New Delhi', 'assets/dummyprofile.png', 'Message'),
                                _personCard('Aryna Gupta', 'buyer/seller/investor', 'Mumbai', 'assets/dummyprofile.png', 'Connect'),
                                _personCard('Amit Kumar', 'buyer/seller/investor', 'Jaipur', 'assets/dummyprofile.png', 'Connect'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
    );
  }

  Widget _infoCard(String label, String value) {
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF23262B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _personCard(String name, String role, String city, String image, String action) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3339),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage(image),
          ),
          const SizedBox(height: 8),
          Text(name, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          Text(role, style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 11)),
          Text(city, style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 11)),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0262AB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 6),
              ),
              child: Text(action, style: const TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
