import 'package:flutter/material.dart';

class ProfileStatusScreen extends StatelessWidget {
  const ProfileStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    Widget buildTile(String title, bool isComplete, VoidCallback onTap, {bool isLarge = false}) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: isLarge ? width * 0.4 : double.infinity,
          height: isLarge ? height * 0.15 : height * 0.1,
          padding: EdgeInsets.all(width * 0.04),
          margin: EdgeInsets.symmetric(vertical: height * 0.008, horizontal: width * 0.015),
          decoration: BoxDecoration(
            color: const Color(0xFF2E3339),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.06,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Icon(
                  isComplete ? Icons.check_circle : Icons.cancel,
                  color: isComplete ? Colors.green : Colors.red,
                  size: width * 0.06,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Column(
              children: [
                SizedBox(height: height * 0.1),
                Text(
                  'Complete your profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.06,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: height * 0.03),

                /// Grid for first 4 large tiles
                Wrap(
                  spacing: width * 0.02,
                  runSpacing: height * 0.015,
                  children: [
                    buildTile('Overview', true, () {}, isLarge: true),
                    buildTile('Org. Details', true, () {}, isLarge: true),
                    buildTile('E-KYC', false, () {}, isLarge: true),
                    buildTile('Contact Details', true, () {}, isLarge: true),
                  ],
                ),

                /// Last 2 smaller tiles
                SizedBox(height: height * 0.02),
                buildTile('Preferences', false, () {}, isLarge: false),
                buildTile('Recognition', true, () {}, isLarge: false),

                /// Bottom button
                SizedBox(height: height * 0.04),
                Container(
                  width: double.infinity,
                  height: height * 0.07,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0262AB), Color(0xFF01345A)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Let's Begin",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: height * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
