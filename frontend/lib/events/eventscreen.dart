import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/events/eventtile.dart';
import 'package:reva/posts/postTile.dart';

import '../notification/notification.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var height= MediaQuery.of(context).size.height;
    var width= MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xFF22252A),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: height*0.1,),Padding(
              padding:EdgeInsets.symmetric(horizontal: width*0.05),
              child: Row(
                children: [
                  TriangleIcon(size: 20 , color: Colors.white,),
                  SizedBox(width: width*0.25,),
                  Text("Events", style: GoogleFonts.dmSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white
                  ),)

                ],
              ),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width*0.05),
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
                          const Icon(Icons.search, color: Colors.white70, size: 22),
                          SizedBox(width: width * 0.02),
                          Expanded(
                            child: TextField(
                              style: const TextStyle(color: Colors.white),
                              cursorColor: Colors.white54,
                              decoration: const InputDecoration(
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'New delhi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: height*0.03,),
            EventTile(),
            EventTile(),
            EventTile(),
            EventTile(),

          ],
        ),
      ),
    );
  }
}
