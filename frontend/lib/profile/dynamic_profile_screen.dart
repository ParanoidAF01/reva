import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DynamicProfileScreen extends StatelessWidget {
  final Map<String, dynamic> userInfo;
  final int totalConnections;
  final int eventsAttended;

  const DynamicProfileScreen({
    Key? key,
    required this.userInfo,
    this.totalConnections = 0,
    this.eventsAttended = 0,
  }) : super(key: key);

  Widget _tagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Text(
        tag,
        style: GoogleFonts.dmSans(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    final String userName = (userInfo['user']?['fullName'] ?? userInfo['fullName'] ?? '').toString();
    final String userLocation = (userInfo['location'] ?? userInfo['user']?['location'] ?? '').toString();
    final String userExperience = (userInfo['experience'] ?? userInfo['user']?['experience'] ?? '').toString();
    final String userLanguages = (userInfo['language'] ?? userInfo['languages'] ?? userInfo['user']?['language'] ?? userInfo['user']?['languages'] ?? '').toString();
    final String profileImage = (userInfo['profilePicture'] ?? userInfo['user']?['profilePicture'] ?? 'assets/dummyprofile.png').toString();
    final String email = (userInfo['user']?['email'] ?? userInfo['email'] ?? '').toString();
    final String phone = (userInfo['user']?['mobileNumber'] ?? userInfo['mobileNumber'] ?? '').toString();

    int totalConnections = 0;
    int eventsAttended = 0;
    if (userInfo['connections'] is List) {
      totalConnections = userInfo['connections'].length;
    } else if (userInfo['totalConnections'] != null) {
      totalConnections = userInfo['totalConnections'];
    }
    if (userInfo['eventsAttended'] is List) {
      eventsAttended = userInfo['eventsAttended'].length;
    } else if (userInfo['eventsAttended'] != null) {
      eventsAttended = userInfo['eventsAttended'];
    }

    final String propertyType = (userInfo['preferences']?['propertyType'] ?? '').toString();
    final List interests = (userInfo['preferences']?['interests'] is List) ? userInfo['preferences']['interests'] : <dynamic>[];

    String medalAsset = 'assets/bronze.png';
    if (eventsAttended >= 60) {
      medalAsset = 'assets/gold.png';
    } else if (eventsAttended >= 20) {
      medalAsset = 'assets/silver.png';
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF22252A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Profile",
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF22252A),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/profile_background.png',
                fit: BoxFit.cover,
              ),
            ),
            Container(
              height: height,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: height * 0.03),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: width * 0.16,
                      backgroundImage: (profileImage.isNotEmpty && !profileImage.contains('assets/')) ? NetworkImage(profileImage) : const AssetImage('assets/dummyprofile.png') as ImageProvider,
                    ),
                    SizedBox(height: height * 0.012),
                    Text(
                      userName.length > 15 ? '${userName.substring(0, 15)}...' : userName,
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (userLocation.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          userLocation,
                          style: GoogleFonts.dmSans(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    SizedBox(height: height * 0.008),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (userExperience.isNotEmpty)
                          Text(
                            '$userExperience yrs+',
                            style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 14),
                          ),
                        if (userLanguages.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              userLanguages,
                              style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 14),
                            ),
                          ),
                      ],
                    ),
                    if (propertyType.isNotEmpty || interests.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Wrap(
                          spacing: 10,
                          children: [
                            if (propertyType.isNotEmpty) _tagChip(propertyType),
                            ...interests.map<Widget>((tag) => _tagChip(tag.toString())),
                          ],
                        ),
                      ),
                    SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.people, color: Colors.white, size: 28),
                                SizedBox(height: 6),
                                if (totalConnections >= 0)
                                  Text(
                                    totalConnections.toString(),
                                    style: GoogleFonts.dmSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                SizedBox(height: 2),
                                Text(
                                  'Total Connections',
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.celebration, color: Colors.white, size: 28),
                                SizedBox(height: 6),
                                if (eventsAttended >= 0)
                                  Text(
                                    eventsAttended.toString(),
                                    style: GoogleFonts.dmSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                SizedBox(height: 2),
                                Text(
                                  'Events Attended',
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 80),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (phone.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.phone, color: Colors.white70, size: 18),
                                const SizedBox(width: 8),
                                Text(phone, style: GoogleFonts.dmSans(color: Colors.white, fontSize: 15)),
                              ],
                            ),
                          if (email.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.email, color: Colors.white70, size: 18),
                                  const SizedBox(width: 8),
                                  Text(email, style: GoogleFonts.dmSans(color: Colors.white, fontSize: 15)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
