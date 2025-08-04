import 'package:flutter/material.dart';
import 'package:reva/events/event_model.dart' as event_model;
import 'package:reva/events/event_detail_screen.dart';

class EventTile extends StatelessWidget {
  final event_model.EventModel event;
  const EventTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Center(
        child: Container(
          width: screenWidth * 0.9,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2E3339),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left Side (Text Content)
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.location,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text("🔥", style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          event.seatsLeft,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailScreen(eventId: event.title),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          backgroundColor: const Color(0xFF0262AB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Right Side (Image with Stack)
              Expanded(
                flex: 4, // reduced width
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: [
                      Container(
                        height: 160, // adjust as needed
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias, // Ensures children respect border radius
                        child: Stack(
                          children: [
                            // Full-size image
                            Positioned.fill(
                              child: event.imageUrl.isNotEmpty ? Image.network(event.imageUrl, fit: BoxFit.cover) : Image.asset("assets/eventdummyimage.png", fit: BoxFit.cover),
                            ),

                            // Bottom black gradient
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: 40, // adjust height of black shade if needed
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(1),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 34,
                        right: 10,
                        child: Text(
                          event.price,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.6),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 14,
                        right: 10,
                        child: Text(
                          event.description,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.white70,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
