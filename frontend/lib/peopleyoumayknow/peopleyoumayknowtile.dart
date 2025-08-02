import 'package:flutter/material.dart';

class PeopleYouMayKnowCard extends StatelessWidget {
  const PeopleYouMayKnowCard({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      // Remove the fixed width line: width: width * 0.42,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12), // Reduced vertical padding
      decoration: BoxDecoration(
        color: const Color(0xFF2F3338), // extracted from image
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important: minimizes the column height
        children: [
          // Profile Picture with white border
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
            ),
            child: CircleAvatar(
              radius: width * 0.09, // Slightly smaller for grid
              backgroundImage: const AssetImage('assets/dummyprofile.png'),
            ),
          ),
          const SizedBox(height: 8), // Reduced spacing

          // Name
          const Text(
            'Aryna Gupta',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3), // Reduced spacing

          // Subtitle (multiline)
          const Text(
            'buyer/seller/\ninvestor',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFB1B5BA),
              fontSize: 13.5,
              height: 1.3, // Reduced line height
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4), // Reduced spacing

          // Location aligned right
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Mumbai',
              style: TextStyle(
                color: Color(0xFFB1B5BA),
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 8), // Reduced spacing

          // Connect Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0184FF), Color(0xFF0168D1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                // connect action
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8), // Reduced button padding
                child: Center(
                  child: Text(
                    'Connect',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Minimal space after button - you can adjust or remove this
          const SizedBox(height: 4), // Very small space after button
        ],
      ),
    );
  }
}