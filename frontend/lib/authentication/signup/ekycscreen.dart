import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/authentication/signup/contactdetailsscreen.dart';

class EKycScreen extends StatelessWidget {
  final bool showBack;
  const EKycScreen({Key? key, this.showBack = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.07),
              if (showBack)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              Center(
                child: Text(
                  'E-KYC Verification',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * 0.04),

              /// Progress Text
              Row(
                children: [
                  Text(
                    "40%   ",
                    style: GoogleFonts.dmSans(
                        color: const Color(0xFFD8D8DD),
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    "Completed..",
                    style: GoogleFonts.dmSans(
                      color: const Color(0xFF6F6F6F),
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: width * 0.6,
                  child: const LinearProgressIndicator(
                    value: 0.4,
                    minHeight: 6,
                    backgroundColor: Colors.white,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Color(0xFF0262AB)),
                  ),
                ),
              ),
              SizedBox(height: height * 0.04),

              /// Aadhaar Label
              const Text(
                'Adhar Card Number',
                style: TextStyle(
                  color: Color(0xFFD8D8DD),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: height * 0.01),

              /// Aadhaar Input
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2E3138),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '0000 0000 0000',
                    hintStyle: TextStyle(color: Color(0xFF6F6F6F)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),

              SizedBox(height: height * 0.02),

              /// Get OTP
              const Center(
                child: Text(
                  'Get OTP',
                  style: TextStyle(
                    color:Color(0xFFFCFCFC)
                  ,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),

              SizedBox(height: height * 0.03),

              /// OTP Label and Resend
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enter OTP',
                    style: TextStyle(
                      color: Color(0xFFD8D8DD),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'resend',
                    style: TextStyle(
                      color: Color(0xFF6F6F6F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.015),

              /// OTP Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                      (index) => Container(
                    height: height * 0.06,
                    width: width * 0.11,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E3138),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),

              SizedBox(height: height * 0.05),

              /// Verify Button
              InkWell(
                onTap: (){
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const ContactDetailsScreen()),
                    (route) => false,
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: height * 0.065,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0262AB),
                        Color(0xFF01345A),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Verify and Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
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
