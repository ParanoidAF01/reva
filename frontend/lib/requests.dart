import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/bottomnavigation/bottomnavigation.dart';

class RequestsPage extends StatelessWidget {
  const RequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: height * 0.09),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: height * 0.07),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).maybePop();
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 26),
                        ),
                        SizedBox(width: width * 0.13),
                        Text(
                          'Requests',
                          style: GoogleFonts.dmSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18),
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
                                const Icon(Icons.search, color: Colors.white70, size: 22),
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
                        InkWell(
                          onTap: () {},
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
                  SizedBox(height: 18),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Row(
                      children: [
                        Text(
                          '4 new request',
                          style: GoogleFonts.dmSans(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.delete, color: Colors.white54, size: 22),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  // Requests List
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Column(
                      children: [
                        _requestTile('Aryna Gupta', 'buyer/seller/investor', 'Scan QR', 'assets/dummyprofile.png'),
                        SizedBox(height: 14),
                        _requestTile('Piyush Patyal', 'buyer/seller/investor', 'Scan QR', 'assets/dummyprofile.png'),
                        SizedBox(height: 14),
                        _requestTile('Uttkarsh Singh', 'buyer/seller/investor', 'Scan QR', 'assets/dummyprofile.png'),
                        SizedBox(height: 14),
                        _requestTile('Abhik Bose', 'buyer/seller/investor', 'Scan QR', 'assets/dummyprofile.png'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // BottomNavigation bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: height * 0.09,
              child: const BottomNavigation(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestTile(String name, String subtitle, String buttonText, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2B2F34),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundImage: AssetImage(imagePath),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0262AB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
