import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reva/profile/help_center_screen.dart';
import 'package:reva/services/auth_service.dart';
import 'package:reva/authentication/welcomescreen.dart';
import 'package:reva/start_subscription.dart';
import 'edit_profile_screen.dart';
import '../providers/user_provider.dart';

class _ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileStatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF23262B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final IconData? icon;
  final String? assetPath;
  final VoidCallback onTap;
  const _SocialIconButton({this.icon, this.assetPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
                    child: Image.asset(assetPath!, fit: BoxFit.contain),
                  )
                : null,
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
              child: Row(
                children: [
                  Text(
                    "Profile",
                    style: GoogleFonts.dmSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white, size: 24),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: const Color(0xFF23262B),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                        ),
                        builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.account_balance_wallet, color: Colors.white),
                                title: const Text('Wallet', style: TextStyle(color: Colors.white)),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pushNamed('/wallet');
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.person, color: Colors.white),
                                title: const Text('Get Subscription', style: TextStyle(color: Colors.white)),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const StartSubscriptionPage()),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.help_center, color: Colors.white),
                                title: const Text('Help Center', style: TextStyle(color: Colors.white)),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.notifications, color: Colors.white),
                                title: const Text('Notifications', style: TextStyle(color: Colors.white)),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pushNamed('/notification');
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.logout, color: Colors.white),
                                title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                                onTap: () async {
                                  await AuthService().logout();
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                                    (route) => false,
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.03),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: height * 0.22,
                  width: width,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1B2B3A),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Builder(
                          builder: (context) {
                            final String? profilePic = userProvider.userData?['profilePicture'];
                            final bool hasProfilePic = profilePic != null && profilePic.isNotEmpty && !profilePic.contains('assets/');
                            return CircleAvatar(
                              radius: 54,
                              backgroundImage: hasProfilePic ? NetworkImage(profilePic) : const AssetImage('assets/dummyprofile.png') as ImageProvider,
                            );
                          },
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.edit, size: 18, color: Color(0xFF0262AB)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userProvider.userName,
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userProvider.userData?['location'] ?? 'Location not set',
                      style: GoogleFonts.dmSans(
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: height * 0.03),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time, color: Colors.white70, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    (userProvider.userData?['experience'] != null ? (userProvider.userData!['experience'].toString().isNotEmpty ? userProvider.userData!['experience'].toString() + ' yrs+' : 'Experience not set') : 'Experience not set'),
                    style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.circle, color: Colors.white38, size: 6),
                  const SizedBox(width: 16),
                  Text((userProvider.userData?['languages'] != null ? (userProvider.userData!['languages'].toString().isNotEmpty ? userProvider.userData!['languages'] : 'Languages not set') : 'Languages not set'), style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            SizedBox(height: height * 0.025),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _ProfileStatCard(
                      icon: Icons.people,
                      label: 'Total Connections',
                      value: userProvider.userData?['totalConnections']?.toString() ?? '0',
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _ProfileStatCard(
                      icon: Icons.celebration,
                      label: 'Events Attended',
                      value: userProvider.userData?['eventsAttended']?.toString() ?? '0',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.025),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      Text(userProvider.userData?['user']?['mobileNumber'] ?? 'Phone not set', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.email, color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      Text(userProvider.userData?['user']?['email'] ?? 'Email not set', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 15)),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialIconButton(
                    assetPath: 'assets/whatsapp.png',
                    onTap: () async {
                      final url = Uri.parse('https://wa.me/');
                      if (await canLaunch(url.toString())) {
                        await launch(url.toString());
                      }
                    },
                  ),
                  const SizedBox(width: 18),
                  _SocialIconButton(
                    icon: Icons.facebook,
                    onTap: () async {
                      final url = Uri.parse('https://facebook.com');
                      if (await canLaunch(url.toString())) {
                        await launch(url.toString());
                      }
                    },
                  ),
                  const SizedBox(width: 18),
                  _SocialIconButton(
                    icon: Icons.camera_alt,
                    onTap: () async {
                      // Open camera app (Android only)
                      // Removed unused cameraScheme variable
                      final url = Uri.parse('intent://camera#Intent;scheme=package;package=com.android.camera;end');
                      if (await canLaunch(url.toString())) {
                        await launch(url.toString());
                      }
                    },
                  ),
                ],
              ),
            ),

            // Sign Out Button
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: width * 0.5,
                    height: 44,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB00020),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        bool error = false;
                        try {
                          await AuthService().logout();
                        } catch (e) {
                          error = true;
                          // Always clear tokens even if API fails
                          await AuthService().deleteToken('accessToken');
                          await AuthService().deleteToken('refreshToken');
                        }
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                            (route) => false,
                          );
                          if (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Session expired or already logged out.')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
