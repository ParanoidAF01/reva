import 'package:reva/editprofile/EditCompleteProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'package:reva/providers/user_provider.dart';
import 'package:reva/editprofile/EditOrganisationDetailsScreen.dart';
import 'package:reva/editprofile/EditEKycScreen.dart';
import 'package:reva/editprofile/EditContactDetailsScreen.dart';
import 'package:reva/editprofile/EditPreferencesScreen.dart';
import 'package:reva/editprofile/EditSpecializationAndRecognition.dart';
import 'package:reva/services/api_service.dart';

class ProfilePercentageScreen extends StatefulWidget {
  const ProfilePercentageScreen({Key? key}) : super(key: key);

  @override
  State<ProfilePercentageScreen> createState() => _ProfilePercentageScreenState();
}

class _ProfilePercentageScreenState extends State<ProfilePercentageScreen> with RouteAware {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeObserver = ModalRoute.of(context)?.navigator?.widget.observers.whereType<RouteObserver<PageRoute>>().firstOrNull;
    routeObserver?.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    final routeObserver = ModalRoute.of(context)?.navigator?.widget.observers.whereType<RouteObserver<PageRoute>>().firstOrNull;
    routeObserver?.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {
      _profileFuture = _fetchProfile();
    });
  }

  Future<Map<String, dynamic>> _fetchProfile() async {
    final response = await ApiService().get('/profiles/me');
    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch profile');
    }
  }

  Map<String, bool> _getSectionStatus(Map<String, dynamic> profile) {
    // Define required fields for each section
    return {
      'Overview': (profile['fullName'] != null && profile['dateOfBirth'] != null && profile['designation'] != null && profile['location'] != null),
      'Org. Details': profile['organization'] != null && profile['organization']['name'] != null,
      'E-KYC': profile['aadharNumber'] != null || profile['panNumber'] != null || profile['kycVerified'] == true,
      'Contact Details': profile['alternateNumber'] != null || (profile['socialMediaLinks'] != null && profile['socialMediaLinks'].isNotEmpty),
      'Preferences': profile['preferences'] != null && profile['preferences'].isNotEmpty,
      'Recognition': profile['specialization'] != null && profile['specialization'].isNotEmpty,
    };
  }

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
      fontSize: 13,
    );
    final subLabelStyle = GoogleFonts.dmSans(
      color: Colors.white70,
      fontWeight: FontWeight.w400,
      fontSize: 14,
    );

    Widget buildSectionCard(String label, IconData icon, bool completed, Future<void> Function() onTap) {
      return GestureDetector(
        onTap: () async {
          await onTap();
        },
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Removed completed/not completed text
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
          onPressed: () async {
            // Update global user state before going back
            try {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              await userProvider.loadUserData();
            } catch (_) {}
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No profile data found', style: TextStyle(color: Colors.white)));
            }
            final profile = snapshot.data!;
            final sectionStatus = _getSectionStatus(profile);
            final completedCount = sectionStatus.values.where((v) => v).length;
            final totalCount = sectionStatus.length;
            final percent = completedCount / totalCount;
            final percentInt = (percent * 100).round();

            return SingleChildScrollView(
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
                          width: width * 0.32,
                          height: width * 0.32,
                          child: CircularProgressIndicator(
                            value: percent,
                            strokeWidth: 8,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0262AB)),
                          ),
                        ),
                        SizedBox(
                          width: width * 0.22,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$percentInt%',
                                style: GoogleFonts.dmSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 1.0),
                                child: Text(
                                  'Profile complete',
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Icon(Icons.check_circle, color: completedColor, size: 18),
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
                                () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditCompleteProfileScreen(),
                                    ),
                                  );
                                  setState(() {
                                    _profileFuture = _fetchProfile();
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: buildSectionCard(
                                'Org. Details',
                                Icons.apartment,
                                sectionStatus['Org. Details']!,
                                () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditOrganisationDetailsScreen(),
                                    ),
                                  );
                                  setState(() {
                                    _profileFuture = _fetchProfile();
                                  });
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
                                () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditEKycScreen(),
                                    ),
                                  );
                                  setState(() {
                                    _profileFuture = _fetchProfile();
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: buildSectionCard(
                                'Contact Details',
                                Icons.phone,
                                sectionStatus['Contact Details']!,
                                () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditContactDetailsScreen(),
                                    ),
                                  );
                                  setState(() {
                                    _profileFuture = _fetchProfile();
                                  });
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
                                () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditPreferencesScreen(),
                                    ),
                                  );
                                  setState(() {
                                    _profileFuture = _fetchProfile();
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: buildSectionCard(
                                'Recognition',
                                Icons.emoji_events,
                                sectionStatus['Recognition']!,
                                () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditSpecializationAndRecognition(),
                                    ),
                                  );
                                  setState(() {
                                    _profileFuture = _fetchProfile();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Removed Continue button
                    SizedBox(height: height * 0.04),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
