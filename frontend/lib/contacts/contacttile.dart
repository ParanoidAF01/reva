import 'package:flutter/material.dart';

class ContactTile extends StatelessWidget {
  const ContactTile({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3237),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Profile Image
          CircleAvatar(
            radius: width * 0.06,
            backgroundImage: const AssetImage('assets/dummyprofile.png'),
          ),
          const SizedBox(width: 12),

          // Name & Subtitle
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aryna Gupta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Kolkata, New Delhi',
                  style: TextStyle(
                    color: Color(0xFFB2B8BD),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Last contacted: 2 days ago',
                  style: TextStyle(
                    color: Color(0xFF8A9299),
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Status: Active',
                  style: TextStyle(
                    color: Color(0xFF8A9299),
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Notes: Interested in 3BHK, prefers morning calls.',
                  style: TextStyle(
                    color: Color(0xFF8A9299),
                    fontSize: 11.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Custom Gradient Button
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0262AB),
                  Color(0xFF01345A)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: InkWell(
              onTap: () {
                // Handle tap
              },
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Text(
                  'View',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
