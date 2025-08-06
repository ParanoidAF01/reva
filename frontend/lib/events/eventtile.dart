import 'package:flutter/material.dart';
import 'package:reva/events/event_model.dart' as event_model;
import 'package:reva/events/event_detail_screen.dart';

class EventTile extends StatelessWidget {
  final event_model.EventModel event;
  const EventTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    String _monthName(int m) {
      const months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec"
      ];
      return months[m - 1];
    }

    String _formatDate(String iso) {
      try {
        final dt = DateTime.parse(iso);
        return "${_monthName(dt.month)} ${dt.day}, ${dt.year}";
      } catch (_) {
        return iso;
      }
    }

    String _formatTime(String iso) {
      try {
        final dt = DateTime.parse(iso);
        int hour = dt.hour;
        int minute = dt.minute;
        String ampm = hour >= 12 ? "PM" : "AM";
        hour = hour > 12 ? hour - 12 : hour;
        return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $ampm";
      } catch (_) {
        return iso;
      }
    }

    String formattedDate = _formatDate(event.startDate);
    String formattedTime = _formatTime(event.startTime);
    final screenWidth = MediaQuery.of(context).size.width;

    final int attendeeCount = event.attendees.length;
    final int maxAttendees = event.maxAttendees;
    final double progress = (maxAttendees > 0 && attendeeCount >= 0) ? attendeeCount / maxAttendees : 0.0;
    Color progressColor;
    if (progress < 0.2) {
      progressColor = Colors.red;
    } else if (progress < 0.5) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.blue;
    }
    String seatsText = maxAttendees > 0 ? "${attendeeCount} of ${maxAttendees} Seats left" : "";

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Center(
        child: Container(
          width: screenWidth * 0.92,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF2E3339),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Side (Text Content)
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      event.location,
                      style: TextStyle(
                        fontSize: screenWidth * 0.032,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      // Date and time
                      formattedDate + " | " + formattedTime,
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (seatsText.isNotEmpty)
                      Text(
                        seatsText,
                        style: TextStyle(
                          fontSize: screenWidth * 0.032,
                          color: progressColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (seatsText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 5,
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailScreen(eventId: event.id),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          backgroundColor: const Color(0xFF0262AB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Right Side (Image with Stack)
              Expanded(
                flex: 5,
                child: Container(
                  height: screenWidth * 0.28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: event.imageUrl.isNotEmpty ? Image.network(event.imageUrl, fit: BoxFit.cover) : Image.asset("assets/eventdummyimage.png", fit: BoxFit.cover),
                      ),
                      // Price and description overlay (bottom, dark background)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(14),
                              bottomRight: Radius.circular(14),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "₹${event.price}",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.07,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.7),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                event.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.032,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
