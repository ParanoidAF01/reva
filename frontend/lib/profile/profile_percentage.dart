import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reva/editprofile/EditCompleteProfileScreen.dart';
import 'package:reva/editprofile/EditContactDetailsScreen.dart';
import 'package:reva/editprofile/EditEKycScreen.dart';
import 'package:reva/editprofile/EditOrganisationDetailsScreen.dart';
import 'package:reva/editprofile/EditPreferencesScreen.dart';
import 'package:reva/editprofile/EditSpecializationAndRecognition.dart';
import '../providers/user_provider.dart';
import 'profile_screen.dart';



class ProfilePercentageScreen extends StatelessWidget {
  ProfilePercentageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final cardColor = const Color(0xFF23262B);
    final completedColor = const Color(0xFF1CBF6B);
    final incompleteColor = const Color(0xFFE74C3C);
    final textColor = Colors.white;
    final labelStyle = GoogleFonts.dmSans(
      color: textColor,
      fontWeight: FontWeight.w700,
      fontSize: 18,
    );
    final subLabelStyle = GoogleFonts.dmSans(
      color: Colors.white70,
      fontWeight: FontWeight.w400,
      fontSize: 14,
    );

    final userData = Provider.of<UserProvider>(context).userData ?? {};

    // Section completion logic
    bool overviewComplete = (userData['fullName'] ?? '').toString().isNotEmpty && (userData['dateOfBirth'] ?? '').toString().isNotEmpty && (userData['gender'] ?? '').toString().isNotEmpty;
    bool orgDetailsComplete = (userData['organization'] != null && userData['organization'] is Map && ((userData['organization']['name'] ?? '').toString().isNotEmpty));
    bool ekycComplete = (userData['aadhaarNumber'] ?? '').toString().isNotEmpty || (userData['ekycStatus'] ?? '').toString().toLowerCase() == 'completed' || (userData['kycVerified'] == true);
    bool contactDetailsComplete = (userData['user']?['email'] ?? userData['email'] ?? '').toString().isNotEmpty && (userData['user']?['mobileNumber'] ?? userData['mobileNumber'] ?? '').toString().isNotEmpty;
    bool preferencesComplete = (userData['preferences'] != null && userData['preferences'] is List && (userData['preferences'] as List).isNotEmpty);
    bool recognitionComplete = (userData['recognition'] != null && userData['recognition'] is List && (userData['recognition'] as List).isNotEmpty);

    final Map<String, bool> sectionStatus = {
      'Overview': overviewComplete,
      'Org. Details': orgDetailsComplete,
      'E-KYC': ekycComplete,
      'Contact Details': contactDetailsComplete,
      'Preferences': preferencesComplete,
      'Recognition': recognitionComplete,
    };
    int completedCount = sectionStatus.values.where((v) => v).length;
    int totalCount = sectionStatus.length;
    double percent = totalCount == 0 ? 0 : completedCount / totalCount;
    int percentInt = (percent * 100).round();

    Widget buildSectionCard(String label, IconData icon, bool completed, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: labelStyle,
                      softWrap: true,
                    ),
                    Text(
                      completed ? 'Completed' : 'Not completed',
                      style: subLabelStyle,
                      softWrap: true,
                    ),
                  ],
                ),
              ),
              // Removed tick and cross icons
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF22252A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Profile Completion', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.04),
                Text(
                  'Complete your profile',
                  style: GoogleFonts.dmSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height * 0.03),
                // Circular progress indicator with percent
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: width * 0.38,
                      height: width * 0.38,
                      child: CircularProgressIndicator(
                        value: percent,
                        strokeWidth: 10,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0262AB)),
                      ),
                    ),
                    SizedBox(
                      width: width * 0.32,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$percentInt%',
                            style: GoogleFonts.dmSans(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Text(
                              'Of your profile is complete \u24d8',
                              style: GoogleFonts.dmSans(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Icon(Icons.check_circle, color: completedColor, size: 32),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.04),
                // Section cards
                Wrap(
                  runSpacing: 8,
                  spacing: 8,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: buildSectionCard(
                            'Overview',
                            Icons.info_outline,
                            sectionStatus['Overview']!,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditCompleteProfileScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: buildSectionCard(
                            'Org. Details',
                            Icons.apartment,
                            sectionStatus['Org. Details']!,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditOrganisationDetailsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: buildSectionCard(
                            'E-KYC',
                            Icons.event,
                            sectionStatus['E-KYC']!,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditEKycScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: buildSectionCard(
                            'Contact Details',
                            Icons.phone,
                            sectionStatus['Contact Details']!,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditContactDetailsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: buildSectionCard(
                            'Preferences',
                            Icons.tune,
                            sectionStatus['Preferences']!,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditPreferencesScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: buildSectionCard(
                            'Recognition',
                            Icons.emoji_events,
                            sectionStatus['Recognition']!,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditSpecializationAndRecognition(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Removed Continue button
              ],
            ),
          ),
        ),
      ),
    );
  }
}
