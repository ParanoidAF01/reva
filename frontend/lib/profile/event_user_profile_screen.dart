import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/services/connections_service.dart';

class EventUserProfileScreen extends StatelessWidget {
  final Map<String, dynamic> userInfo;
  const EventUserProfileScreen({super.key, required this.userInfo});

  String getField(String key) {
    final value = userInfo[key];
    if (value == null || value.toString().isEmpty) {
      return '***********';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    // Dummy values for stats and tags, as attendee info is limited
    final String userName = getField('fullName');
    final String userLocation = getField('location');
    final String userExperience = '';
    final String userLanguages = '';
    final String profileImage = 'assets/dummyprofile.png';
    final int totalConnections = 0;
    final int eventsAttended = 0;
    final String email = getField('email');
    final String phone = getField('phone');
    final String tag1 = '';
    final String tag2 = '';
    final String tag3 = '';
    final String medalAsset = 'assets/bronze.png';
    final ConnectionsService connectionsService = ConnectionsService();

    return Scaffold(
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
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: height * 0.02, left: 16, right: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      Text(
                        "Profile",
                        style: GoogleFonts.dmSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(width: 24),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.03),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: width * 0.16,
                      backgroundImage: AssetImage(profileImage),
                    ),
                    Positioned(
                      bottom: -30,
                      right: -30,
                      child: Image.asset(
                        medalAsset,
                        width: width * 0.30,
                        height: width * 0.30,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.01),
                Text(
                  userName,
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                if (userLocation != '***********' && userLocation.isNotEmpty)
                  Text(
                    userLocation,
                    style: GoogleFonts.dmSans(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                SizedBox(height: height * 0.01),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    width: 180,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          final toUserId = userInfo['id'] ?? userInfo['_id'];
                          if (toUserId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('User ID not found.')),
                            );
                            return;
                          }
                          final res = await connectionsService.sendConnectionRequest(toUserId);
                          if (res['status'] == 201 || res['message']?.toString().contains('success') == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Connection request sent!')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(res['message'] ?? 'Failed to send request.')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ' + e.toString())),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0262AB),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Connect', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (userExperience.isNotEmpty)
                      Text(
                        userExperience,
                        style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 14),
                      ),
                    if (userExperience.isNotEmpty && userLanguages.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white38,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    if (userLanguages.isNotEmpty)
                      Text(
                        userLanguages,
                        style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 14),
                      ),
                  ],
                ),
                SizedBox(height: height * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (tag1.isNotEmpty) _tagChip(tag1),
                    if (tag2.isNotEmpty) ...[
                      SizedBox(width: 8),
                      _tagChip(tag2),
                    ],
                    if (tag3.isNotEmpty) ...[
                      SizedBox(width: 8),
                      _tagChip(tag3),
                    ],
                  ],
                ),
                SizedBox(height: height * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 12),
                        padding: EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.people, color: Colors.white, size: 28),
                            SizedBox(height: 6),
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
                        margin: EdgeInsets.symmetric(horizontal: 12),
                        padding: EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.celebration, color: Colors.white, size: 28),
                            SizedBox(height: 6),
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
                SizedBox(height: height * 0.06),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone, color: Colors.white70, size: 18),
                          SizedBox(width: 8),
                          Text(phone, style: GoogleFonts.dmSans(color: Colors.white, fontSize: 15)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.email, color: Colors.white70, size: 18),
                          SizedBox(width: 8),
                          Text(email, style: GoogleFonts.dmSans(color: Colors.white, fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialIconButton(assetPath: 'assets/whatsapp.png', onTap: () {}),
                    SizedBox(width: 18),
                    _socialIconButton(icon: Icons.facebook, onTap: () {}),
                    SizedBox(width: 18),
                    _socialIconButton(icon: Icons.camera_alt, onTap: () {}),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _socialIconButton({IconData? icon, String? assetPath, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: Color(0xFF23262B),
          shape: BoxShape.circle,
        ),
        child: icon != null
            ? Icon(icon, color: Colors.white, size: 20)
            : assetPath != null
                ? Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: Image.asset(assetPath, fit: BoxFit.contain),
                  )
                : null,
      ),
    );
  }
}
