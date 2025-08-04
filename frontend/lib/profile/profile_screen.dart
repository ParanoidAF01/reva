import 'package:reva/profile/help_center_screen.dart';
// import 'package:reva/redeem.dart';
import 'package:reva/services/auth_service.dart';
import 'package:reva/authentication/welcomescreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reva/start_subscription.dart';
import 'profile_provider.dart';
import '../providers/user_provider.dart';
import '../services/service_manager.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider(),
      child: Consumer2<ProfileProvider, UserProvider>(
        builder: (context, provider, userProvider, _) {
          return Scaffold(
            backgroundColor: const Color(0xFF22252A),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 16.0, left: 16, right: 16),
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
                          icon: const Icon(Icons.settings,
                              color: Colors.white, size: 24),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: const Color(0xFF23262B),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(18)),
                              ),
                              builder: (context) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(
                                          Icons.account_balance_wallet,
                                          color: Colors.white),
                                      title: const Text('Wallet',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context)
                                            .pushNamed('/wallet');
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.person,
                                          color: Colors.white),
                                      title: const Text('Account',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const StartSubscriptionPage()),
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.help_center,
                                          color: Colors.white),
                                      title: const Text('Help Center',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const HelpCenterScreen()),
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.notifications,
                                          color: Colors.white),
                                      title: const Text('Notifications',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      onTap: () {},
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.logout,
                                          color: Colors.white),
                                      title: const Text('Sign Out',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      onTap: () async {
                                        await AuthService().logout();
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const WelcomeScreen()),
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
                              const CircleAvatar(
                                radius: 54,
                                backgroundImage:
                                    AssetImage('assets/dummyprofile.png'),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => _showEditProfileDialog(
                                      context, provider, userProvider),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(Icons.edit,
                                        size: 18, color: Color(0xFF0262AB)),
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
                            userProvider.userData?['location'] ??
                                'Location not set',
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
                        const Icon(Icons.access_time,
                            color: Colors.white70, size: 18),
                        const SizedBox(width: 6),
                        Text(
                            userProvider.userData?['experience'] ??
                                'Experience not set',
                            style: GoogleFonts.dmSans(
                                color: Colors.white70, fontSize: 14)),
                        const SizedBox(width: 16),
                        const Icon(Icons.circle,
                            color: Colors.white38, size: 6),
                        const SizedBox(width: 16),
                        Text(
                            userProvider.userData?['languages'] ??
                                'Languages not set',
                            style: GoogleFonts.dmSans(
                                color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.025),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ProfileStatCard(
                            icon: Icons.people,
                            label: 'Total Connections',
                            value: userProvider.userData?['totalConnections']
                                    ?.toString() ??
                                '0'),
                        const SizedBox(width: 18),
                        _ProfileStatCard(
                            icon: Icons.celebration,
                            label: 'Events Attended',
                            value: userProvider.userData?['eventsAttended']
                                    ?.toString() ??
                                '0'),
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
                            const Icon(Icons.phone,
                                color: Colors.white70, size: 18),
                            const SizedBox(width: 8),
                            Text(
                                userProvider.userData?['user']
                                        ?['mobileNumber'] ??
                                    'Phone not set',
                                style: GoogleFonts.dmSans(
                                    color: Colors.white, fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.email,
                                color: Colors.white70, size: 18),
                            const SizedBox(width: 8),
                            Text(
                                userProvider.userData?['user']?['email'] ??
                                    'Email not set',
                                style: GoogleFonts.dmSans(
                                    color: Colors.white, fontSize: 15)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialIcon.asset(assetPath: 'assets/whatsapp.png'),
                        SizedBox(width: 18),
                        _SocialIcon(icon: Icons.facebook),
                        SizedBox(width: 18),
                        _SocialIcon(icon: Icons.camera_alt),
                      ],
                    ),
                  ),

                  // Sign Out Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: SizedBox(
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
                        label: const Text('Sign Out',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
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
                              MaterialPageRoute(
                                  builder: (_) => const WelcomeScreen()),
                              (route) => false,
                            );
                            if (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Session expired or already logged out.')),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, ProfileProvider provider,
      UserProvider userProvider) {
    final locationController =
        TextEditingController(text: userProvider.userData?['location'] ?? '');
    final experienceController =
        TextEditingController(text: userProvider.userData?['experience'] ?? '');
    final languagesController =
        TextEditingController(text: userProvider.userData?['languages'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF23262B),
          title: Text('Edit Profile',
              style: GoogleFonts.dmSans(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _editField('Location', locationController),
                _editField('Experience', experienceController),
                _editField('Languages', languagesController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0262AB),
              ),
              onPressed: () async {
                try {
                  // Update profile via API
                  final response =
                      await ServiceManager.instance.profile.updateProfile({
                    'location': locationController.text,
                    'experience': experienceController.text,
                    'languages': languagesController.text,
                  });

                  if (response['success'] == true) {
                    // Reload user data to reflect changes
                    await userProvider.loadUserData();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Profile updated successfully!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(response['message'] ??
                              'Failed to update profile')),
                    );
                  }
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating profile: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _editField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF0262AB)),
          ),
        ),
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileStatCard(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
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
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData? icon;
  final String? assetPath;
  const _SocialIcon({this.icon}) : assetPath = null;
  const _SocialIcon.asset({required this.assetPath}) : icon = null;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
