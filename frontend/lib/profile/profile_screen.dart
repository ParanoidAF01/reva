import 'package:flutter/material.dart';
import 'package:reva/profile/profile_percentage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reva/services/service_manager.dart';
import 'package:reva/profile/help_center_screen.dart';
import 'package:reva/services/auth_service.dart';
import 'package:reva/start_subscription.dart';
import 'edit_profile_screen.dart';
import '../providers/user_provider.dart';
import '../utils/navigation_helper.dart';
import 'package:share_plus/share_plus.dart';

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
  final VoidCallback onTap;
  const _SocialIconButton({this.icon, required this.onTap});

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
        child: icon != null ? Icon(icon, color: Colors.white, size: 20) : null,
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with RouteAware {
  RouteObserver<PageRoute>? _routeObserver;
  int totalConnections = 0;
  int eventsAttended = 0;
  bool _loadingEvents = true;

  void _shareProfile(String name, String email, String website, String social) {
    final text = 'Check out $name\'s profile!\nEmail: $email\nWebsite: $website\nSocial: $social';
    // Use share_plus
    Share.share(text);
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfileAndCounts();
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
    _fetchUserProfileAndCounts();
    setState(() {});
  }

  Future<void> _fetchUserProfileAndCounts() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUserData();
    await fetchCounts();
  }

  Future<void> fetchCounts() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userData = userProvider.userData ?? {};
    setState(() {
      totalConnections = userData['numberOfConnections'] ?? 0;
    });
    try {
      final response = await ServiceManager.instance.events.getMyEvents();
      if (response['success'] == true) {
        setState(() {
          eventsAttended = (response['data']['events'] as List).length;
          _loadingEvents = false;
        });
      } else {
        setState(() {
          eventsAttended = 0;
          _loadingEvents = false;
        });
      }
    } catch (e) {
      setState(() {
        eventsAttended = 0;
        _loadingEvents = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.userData ?? {};
    final String userName = userProvider.userName;
    final String userLocation = userData['location'] ?? "";
    final String userExperience = userData['experience'] != null && userData['experience'].toString().isNotEmpty ? "${userData['experience'].toString()} yrs+" : "";
    final String userLanguages = userData['language'] ?? "";
    final String profileImage = userData['profilePicture'] ?? userData['profileImage'] ?? 'assets/dummyprofile.png';
    final String email = userData['user']?['email'] ?? userData['email'] ?? '';
    final String phone = userData['user']?['mobileNumber'] ?? userData['mobileNumber'] ?? '';
    final String tag1 = (userData['preferences'] != null && userData['preferences']['propertyType'] != null && userData['preferences']['propertyType'].toString().isNotEmpty) ? userData['preferences']['propertyType'] : "";
    final String tag2 = (userData['preferences'] != null && userData['preferences']['interests'] is List && (userData['preferences']['interests'] as List).isNotEmpty) ? (userData['preferences']['interests'] as List)[0].toString() : "";

    // Medal logic
    String medalAsset = '';
    if (eventsAttended < 20) {
      medalAsset = 'assets/bronze.png';
    } else if (eventsAttended < 60) {
      medalAsset = 'assets/silver.png';
    } else {
      medalAsset = 'assets/gold.png';
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF22252A),
        elevation: 0,
        leading: const SizedBox(),
        title: Text(
          "Profile",
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
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
                        leading: const Icon(Icons.edit, color: Colors.white),
                        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ProfilePercentageScreen()),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.white),
                        title: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await AuthService.performCompleteLogout();
                          NavigationHelper.navigateToWelcomeScreen();
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
            // Container with fixed height matching viewport
            Container(
              height: height,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: height * 0.03),
                child: Column(
                  children: [
                    SizedBox(height: height * 0.03),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                            );
                          },
                          child: CircleAvatar(
                            radius: width * 0.16,
                            backgroundImage: (profileImage.isNotEmpty && !profileImage.contains('assets/')) ? NetworkImage(profileImage) : const AssetImage('assets/dummyprofile.png') as ImageProvider,
                          ),
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
                      Text(
                        userLocation,
                        style: GoogleFonts.dmSans(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                    SizedBox(height: height * 0.01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (userExperience.isNotEmpty)
                          Text(
                            userExperience,
                            style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 14),
                          ),
                        if (userExperience.isNotEmpty && userLanguages.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('•', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
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
                        if (tag1.isNotEmpty && tag2.isNotEmpty) const SizedBox(width: 8),
                        if (tag2.isNotEmpty) _tagChip(tag2),
                      ],
                    ),
                    SizedBox(height: height * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 25),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.people, color: Colors.white, size: 28),
                                const SizedBox(height: 6),
                                Text(
                                  totalConnections.toString(),
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(height: 2),
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
                            margin: const EdgeInsets.symmetric(horizontal: 25),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.celebration, color: Colors.white, size: 28),
                                const SizedBox(height: 6),
                                Text(
                                  eventsAttended.toString(),
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(height: 2),
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
                              const Icon(Icons.phone, color: Colors.white70, size: 18),
                              const SizedBox(width: 8),
                              Text(phone, style: GoogleFonts.dmSans(color: Colors.white, fontSize: 15)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.email, color: Colors.white70, size: 18),
                              const SizedBox(width: 8),
                              Text(email, style: GoogleFonts.dmSans(color: Colors.white, fontSize: 15)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialIconButton(
                          icon: Icons.language,
                          onTap: () async {
                            final website = userData['socialMediaLinks']?['website'] ?? '';
                            if (website.isNotEmpty) {
                              final url = Uri.parse(website.startsWith('http') ? website : 'https://$website');
                              if (await canLaunch(url.toString())) {
                                await launch(url.toString());
                              }
                            }
                          },
                        ),
                        const SizedBox(width: 18),
                        _SocialIconButton(
                          icon: Icons.alternate_email,
                          onTap: () async {
                            final social = userData['socialMediaLinks']?['instagram'] ?? userData['socialMediaLinks']?['facebook'] ?? '';
                            if (social.isNotEmpty) {
                              final url = Uri.parse(social.startsWith('http') ? social : 'https://$social');
                              if (await canLaunch(url.toString())) {
                                await launch(url.toString());
                              }
                            }
                          },
                        ),
                        const SizedBox(width: 18),
                        _SocialIconButton(
                          icon: Icons.email,
                          onTap: () async {
                            final emailUrl = 'mailto:${userData['user']?['email'] ?? userData['email'] ?? ''}';
                            if (await canLaunch(emailUrl)) {
                              await launch(emailUrl);
                            }
                          },
                        ),
                        const SizedBox(width: 18),
                        _SocialIconButton(
                          icon: Icons.share,
                          onTap: () {
                            final name = userName;
                            final emailVal = userData['user']?['email'] ?? userData['email'] ?? '';
                            final website = userData['socialMediaLinks']?['website'] ?? '';
                            final social = userData['socialMediaLinks']?['instagram'] ?? userData['socialMediaLinks']?['facebook'] ?? '';
                            _shareProfile(name, emailVal, website, social);
                          },
                        ),
                      ],
                    ),
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
