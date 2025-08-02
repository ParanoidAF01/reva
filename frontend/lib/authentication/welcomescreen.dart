import 'package:flutter/material.dart';
import 'package:reva/authentication/onboardingscreen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFF22252A),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: height * 0.10),

            // Logo (centered)
            Center(
              child: Image.asset(
                'assets/logo.png',
                height: height * 0.08, // proportional height
              ),
            ),



            // Title
            Text(
              'Welcome to REVA',
              style: TextStyle(
                fontSize: width * 0.070,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            SizedBox(height: height * 0.005),

            // Subtitle
            Text(
              'Real Estate Verified Agents',
              style: TextStyle(
                fontSize: width * 0.030,
                fontWeight: FontWeight.w400,
                color: Color(0xFFDFDFDF),
              ),
            ),

            Spacer(),

            // Description
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.1),
              child: Text(
                'India’s trusted platform for agent\nnetworking, verified leads, and offline events.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: width * 0.030, // ~13
                  color: Color(0xFFDFDFDF),
                ),
              ),
            ),

            SizedBox(height: height * 0.04),

            // Gradient Get Started Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.1),
              child: Container(
                width: double.infinity,
                height: height * 0.065,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0262AB)
                      , Color(0xFF01345A)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> OnboardingScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: width * 0.045, // ~16
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: height * 0.15),
          ],
        ),
      ),
    );
  }
}
