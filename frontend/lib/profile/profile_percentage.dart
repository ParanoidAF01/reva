import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/authentication/signup/CompleteProfileScreen.dart';
import 'package:reva/authentication/signup/contactdetailsscreen.dart';
import 'package:reva/authentication/signup/ekycscreen.dart';
import 'package:reva/authentication/signup/orginisationdetailscreen.dart';
import 'package:reva/authentication/signup/preferencesScreen.dart';

class ProfilePercentageScreen extends StatelessWidget {
  ProfilePercentageScreen({Key? key}) : super(key: key);

  // Mock completion status for each section
  final Map<String, bool> sectionStatus = const {
    'Overview': true,
    'Org. Details': true,
    'E-KYC': true,
    'Contact Details': true,
    'Preferences': false,
    'Recognition': true,
  };

  int get completedCount => sectionStatus.values.where((v) => v).length;
  int get totalCount => sectionStatus.length;
  double get percent => completedCount / totalCount;
  int get percentInt => (percent * 100).round();

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
                    Text(label, style: labelStyle),
                    Text(completed ? 'Completed' : 'Not completed', style: subLabelStyle),
                  ],
                ),
              ),
              Icon(
                completed ? Icons.check_circle : Icons.cancel,
                color: completed ? completedColor : incompleteColor,
                size: 28,
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$percentInt%',
                          style: GoogleFonts.dmSans(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Of your profile is\ncomplete \u24d8',
                          style: GoogleFonts.dmSans(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Icon(Icons.check_circle, color: completedColor, size: 32),
                      ],
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
                                  builder: (_) => CompleteProfileScreen(showBack: true),
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
                                  builder: (_) => OrganisationDetailsScreen(showBack: true),
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
                                  builder: (_) => EKycScreen(showBack: true),
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
                                  builder: (_) => ContactDetailsScreen(showBack: true),
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
                                  builder: (_) => PreferencesScreen(showBack: true),
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
                              // TODO: Implement Recognition navigation if needed
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: height * 0.06),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Continue action
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0262AB), Color(0xFF01345A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Continue',
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
