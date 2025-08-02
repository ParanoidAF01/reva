import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/home/components/silverCard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xFF22252A),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width*0.05),
          child: Column(
            children: [
              SizedBox(height: height*0.11,),
              Row(
                children: [
                  Image.asset("assets/logo.png",height: 40,),
                  SizedBox(width: width*0.02,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hello!",style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w400,
                        fontSize: height*0.036,
                        color: Colors.white

                      ),),
                      Text("Ayush,", style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700,
                        fontSize: height*0.06,
                        color: Colors.white
                      ),),
                    ],
                  ),
                  Spacer(),
                  Image.asset("assets/bellicon.png"),

                ],
              ),
              SizedBox(height: height*0.05,),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: height * 0.12,
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
                      height: height * 0.12,
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
                          Icon(Icons.filter_list, color: Colors.white, size: 20),
                          SizedBox(width: 6),
                          Text(
                            'Filters',
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
              SizedBox(height: height*0.05,),
              Image.asset("assets/brownCard.png"),
              SizedBox(height: height*0.05,),
              InkWell(
                onTap: () {
                  // Handle tap
                },
                borderRadius: BorderRadius.circular(height * 0.03),
                child: Container(
                  width: double.infinity,
                  height: height * 0.12,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0262AB), Color(0xFF01345A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(height * 0.03),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF01345A).withOpacity(0.45),
                        blurRadius: height * 0.03,
                        offset: Offset(0, height * 0.01),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code,
                        color: Colors.white,
                        size: height * 0.05,
                      ),
                      SizedBox(width: height * 0.015),
                      Text(
                        "View my Profile QR",
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: height * 0.033,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          SizedBox(height: height*0.05,),
          Row(
            children: [
              Container(
                height: height * 0.16,
                width: width * 0.56,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D33), // Dark background from image
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.people,
                      color: const Color(0xFF5C7A99), // Light blue icon from image
                      size: 28,
                    ),
                    Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '028',
                          style: GoogleFonts.dmSans(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFE1E1E1), // Light gray number
                          ),
                        ),
                        Text(
                          'Total no. of connections',
                          style: GoogleFonts.dmSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFB4B4B4), // Subtitle gray
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: width*0.04,),
              Container(
                height: height * 0.16,
                width: width * 0.3,
                decoration: BoxDecoration(
                  color: const Color(0xFF2F3238), // background color from image
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "4 new",
                        style: GoogleFonts.dmSans(
                          fontSize: width * 0.05,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF5F5F5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Want to connect",
                        style: GoogleFonts.dmSans(
                          fontSize: width * 0.032,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFFB2B2B2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
            ],
          ),
        ),
      ),
    );
  }
}
