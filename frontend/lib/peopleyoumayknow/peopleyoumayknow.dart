import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/contacts/contacts.dart';
import 'package:reva/events/eventtile.dart';
import 'package:reva/peopleyoumayknow/peopleyoumayknowtile.dart';
import 'package:reva/posts/postTile.dart';
import 'package:reva/request/requesttile.dart';
import 'package:reva/requests.dart';
import 'package:reva/start_subscription.dart';

import '../notification/notification.dart';

class PeopleYouMayKnow extends StatelessWidget {
  const PeopleYouMayKnow({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: height * 0.1),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Row(
                children: [
                  TriangleIcon(size: 20, color: Colors.white),
                  SizedBox(width: width * 0.15),
                  Text(
                    "People you know",
                    style: GoogleFonts.dmSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: width * 0.12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B2F34),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: Colors.white70,
                            size: 22,
                          ),
                          SizedBox(width: width * 0.02),
                          const Expanded(
                            child: TextField(
                              style: TextStyle(color: Colors.white),
                              cursorColor: Colors.white54,
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: TextStyle(color: Colors.white54),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: width * 0.03),
                  // Filter Button
                  InkWell(
                    onTap: () {
                      // TODO: Add filter action
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: width * 0.12,
                      width: width * 0.2,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0262AB), Color(0xFF01345A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Search',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.03),

            // Find in Contacts Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement find in contacts action
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Contacts()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: height * 0.018),
                    backgroundColor: const Color(0xFF0262AB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Find in Contacts',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement find in contacts action
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RequestsPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: height * 0.018),
                    backgroundColor: const Color(0xFF0262AB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'View Requests',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Grid View for Cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 cards per row
                  crossAxisSpacing:
                      width * 0.03, // Horizontal spacing between cards
                  mainAxisSpacing:
                      height * 0.02, // Vertical spacing between cards
                  childAspectRatio: 0.65, // Adjusted for better proportions
                ),
                itemCount: 7, // Number of cards
                itemBuilder: (context, index) {
                  return const PeopleYouMayKnowCard();
                },
              ),
            ),

            SizedBox(height: height * 0.05), // Bottom padding
          ],
        ),
      ),
    );
  }
}
