import 'package:reva/editprofile/EditCompleteProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'package:reva/providers/user_provider.dart';
import 'package:reva/editprofile/EditOrganisationDetailsScreen.dart';

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
  RouteObserver<PageRoute>? _routeObserver;
  void _showAlreadyVerifiedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF23262B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('E-KYC', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('You are already verified', style: GoogleFonts.dmSans(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: GoogleFonts.dmSans(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }
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
    _routeObserver = routeObserver;
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      _routeObserver?.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    _routeObserver?.unsubscribe(this);
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



  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final cardColor = const Color(0xFF23262B);
    final completedColor = const Color(0xFF1CBF6B);
  // final incompleteColor = const Color(0xFFE74C3C); // Unused, removed
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

            // --- Begin: New Profile Completion Percentage Logic ---
            // 1. List all required and optional fields for each signup page
            // Only required fields for 100% completion:
            // Overview: fullName, dateOfBirth, designation, location, experience
            // Organisation: name, incorporationDate, companyType, registered
            // Contact: mobileNumber, email
            // Preferences: operatingLocations, interests, propertyType, networkingPreferences, targetClients
            // Specialization: reraRegistered, reraNumber (if reraRegistered true)
            // EKYC: aadharNumber, kycVerified (true)
            final requiredFields = <String, dynamic>{
              'fullName': profile['fullName'],
              'dateOfBirth': profile['dateOfBirth'],
              'designation': profile['designation'],
              'location': profile['location'],
              'experience': profile['experience'],
              'companyName': profile['organization']?['name'],
              'incorporationDate': profile['organization']?['incorporationDate'],
              'companyType': profile['organization']?['companyType'],
              'isRegistered': profile['organization']?['registered'],
              'primaryMobileNumber': profile['user']?['mobileNumber'] ?? profile['mobileNumber'],
              'primaryEmailId': profile['user']?['email'] ?? profile['email'],
              'operatingLocations': profile['preferences']?['operatingLocations'],
              'interests': (profile['preferences']?['interests'] is List && (profile['preferences']?['interests'] as List).isNotEmpty) ? (profile['preferences']?['interests'] as List)[0] : null,
              'propertyType': profile['preferences']?['propertyType'],
              'networkingPreferences': profile['preferences']?['networkingPreferences'],
              'targetClients': profile['preferences']?['targetClients'],
              'reraRegistered': profile['specialization']?['reraRegistered'],
              'aadharNumber': profile['aadharNumber'],
              'kycVerified': profile['kycVerified'],
            };
            // reraNumber only required if reraRegistered is true
            if (profile['specialization']?['reraRegistered'] == true) {
              requiredFields['reraNumber'] = profile['specialization']?['reraNumber'];
            }
            int totalFields = 0;
            int filledFields = 0;
            List<String> missingFields = [];
            requiredFields.forEach((key, value) {
              if (value == 'skip') return;
              totalFields++;
              bool isFilled = false;
              if (key == 'aadharNumber' || key == 'fullName') {
                isFilled = true;
              } else if (value != null) {
                if (key == 'kycVerified') {
                  if (value == true) isFilled = true;
                } else if (value is String && value.trim().isNotEmpty) {
                  isFilled = true;
                } else if (value is bool && value == true) {
                  isFilled = true;
                } else if (value is! String && value.toString().isNotEmpty && value != false) {
                  isFilled = true;
                }
              }
              if (isFilled) {
                filledFields++;
              } else {
                missingFields.add(key);
              }
            });
            // Debug print for missing fields
            // ignore: avoid_print
            print('Profile completion missing fields: ' + missingFields.join(', '));
            double percent = totalFields == 0 ? 0.0 : filledFields / totalFields;
            int percentInt = (percent * 100).round();
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
                    const SizedBox(height: 12),
                    Text(
                      'Contact Details',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
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
                    // ...existing code...
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
                                true,
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
                                true,
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
                                'Contact Details',
                                Icons.phone,
                                true,
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
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _showAlreadyVerifiedDialog(context),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.verified, color: Colors.white, size: 28),
                                      const SizedBox(width: 18),
                                      Expanded(
                                        child: Text(
                                          'E-KYC',
                                          style: labelStyle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                                true,
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
                                true,
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
