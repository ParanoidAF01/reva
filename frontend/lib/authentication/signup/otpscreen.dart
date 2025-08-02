import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/authentication/signup/contactdetailsscreen.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

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
              Center(
                child: Text(
                  'Forgot MPIN',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * 0.04),

              const SizedBox(height: 4),

              SizedBox(height: height * 0.04),

              /// Aadhaar Label
              const Text(
                'Enter Your Mobile Number',
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
                    hintText: '00000 00000',
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
                  'Sent OTP',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
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
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> ContactDetailsScreen()));
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
                      'Submit OTP ',
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
