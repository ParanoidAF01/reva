import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reva/home/components/goldCard.dart';
import 'package:reva/home/components/silverCard.dart';
import 'package:reva/home/components/bronzeCard.dart';
import 'package:reva/services/service_manager.dart';
import 'package:reva/home/create_post_card.dart';
import 'package:reva/peopleyoumayknow/peopleyoumayknow.dart';
import 'package:reva/peopleyoumayknow/peopleyoumayknowtile.dart';
import 'package:reva/home/contact_management_section.dart';
import 'package:reva/qr/profile_qr_screen.dart';
import 'package:reva/events/event_detail_screen.dart';
import 'package:reva/events/eventscreen.dart';
import 'package:reva/posts/createpost.dart';
import 'package:reva/providers/user_provider.dart';
import 'package:reva/wallet/walletscreen.dart';

// Make sure the GoldCard widget is defined in GoldCard.dart
// import 'package:reva/qr/profile_qr_screen.dart';
// Make sure ProfileQrScreen is a widget class in this file.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> userEvents = [];
  List<dynamic> upcomingEvents = [];
  List<dynamic> myPosts = [];
  List<dynamic> peopleYouMayKnow = [];
  bool isLoadingEvents = true;
  bool isLoadingUpcomingEvents = true;
  bool isLoadingPosts = true;
  bool isLoadingPeople = true;
  int subscriptionDaysLeft = 0;
  bool subscriptionActive = true;
  bool isLoadingSubscription = true;
  Map<String, dynamic>? subscriptionDetails;

  @override
  void initState() {
    super.initState();
    // Ensure user profile data is loaded for dynamic fields
    Future.microtask(() async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadUserData();
      // Refresh connection counts after loading user data
      await userProvider.refreshConnectionCounts();
    });
    fetchUserEvents();
    fetchUpcomingEvents();
    fetchMyPosts();
    fetchPeopleYouMayKnow();
    fetchSubscriptionStatus();
  }

  Future<void> fetchSubscriptionStatus() async {
    try {
      // Try to load from cache first
      final cached =
          await ServiceManager.instance.subscription.getCachedSubscription();
      if (cached != null) {
        subscriptionDetails = cached['subscription'];
        subscriptionActive = cached['isSubscribed'] ?? false;
        subscriptionDaysLeft = _calculateDaysLeft(cached['subscription']);
        isLoadingSubscription = false;
        setState(() {});
      }
      // Always fetch latest from API
      final response =
          await ServiceManager.instance.subscription.checkSubscription();
      if (response['success'] == true) {
        // Cache the response
        await ServiceManager.instance.subscription
            .cacheSubscription(response['data']);
        subscriptionDetails = response['data']['subscription'];
        subscriptionActive = response['data']['isSubscribed'] ?? false;
        subscriptionDaysLeft =
            _calculateDaysLeft(response['data']['subscription']);
        isLoadingSubscription = false;
        setState(() {});
      } else {
        subscriptionDetails = null;
        subscriptionActive = false;
        subscriptionDaysLeft = 0;
        isLoadingSubscription = false;
        setState(() {});
      }
    } catch (e) {
      subscriptionDetails = null;
      subscriptionActive = false;
      subscriptionDaysLeft = 0;
      isLoadingSubscription = false;
      setState(() {});
    }
  }

  int _calculateDaysLeft(Map<String, dynamic>? subscription) {
    if (subscription == null || subscription['endDate'] == null) return 0;
    final endDate = DateTime.tryParse(subscription['endDate']);
    if (endDate == null) return 0;
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  Future<void> fetchUserEvents() async {
    try {
      final response = await ServiceManager.instance.events.getMyEvents();
      if (response['success'] == true) {
        setState(() {
          userEvents = response['data']['events'] ?? [];
          isLoadingEvents = false;
        });
      } else {
        setState(() {
          userEvents = [];
          isLoadingEvents = false;
        });
      }
    } catch (e) {
      setState(() {
        userEvents = [];
        isLoadingEvents = false;
      });
    }
  }

  Future<void> fetchUpcomingEvents() async {
    try {
      final response = await ServiceManager.instance.events.getAllEvents();
      if (response['success'] == true) {
        setState(() {
          upcomingEvents = response['data']['events'] ?? [];
          isLoadingUpcomingEvents = false;
        });
      } else {
        setState(() {
          upcomingEvents = [];
          isLoadingUpcomingEvents = false;
        });
      }
    } catch (e) {
      setState(() {
        upcomingEvents = [];
        isLoadingUpcomingEvents = false;
      });
    }
  }

  Future<void> fetchMyPosts() async {
    try {
      final response = await ServiceManager.instance.posts.getMyPosts();
      if (response['success'] == true) {
        setState(() {
          myPosts = response['data']['posts'] ?? [];
          isLoadingPosts = false;
        });
      } else {
        setState(() {
          myPosts = [];
          isLoadingPosts = false;
        });
      }
    } catch (e) {
      setState(() {
        myPosts = [];
        isLoadingPosts = false;
      });
    }
  }

  Future<void> fetchPeopleYouMayKnow() async {
    try {
      final response =
          await ServiceManager.instance.connections.getConnectionSuggestions();
      if (response['success'] == true) {
        final suggestions = response['data']['suggestions'] ?? [];
        final mapped = suggestions
            .map((person) => {
                  'name': person['fullName'] ?? 'Unknown',
                  'image': person['profile'] ?? 'assets/dummyprofile.png',
                  'mobileNumber': person['mobileNumber'] ?? '',
                })
            .toList();
        setState(() {
          peopleYouMayKnow = mapped;
          isLoadingPeople = false;
        });
      } else {
        setState(() {
          peopleYouMayKnow = [];
          isLoadingPeople = false;
        });
      }
    } catch (e) {
      setState(() {
        peopleYouMayKnow = [];
        isLoadingPeople = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // Prepare subscription fields safely
    final String plan = subscriptionDetails?['plan']?.toString() ?? '-';
    final int amountPaid = (subscriptionDetails?['amountPaid'] is int)
        ? (subscriptionDetails?['amountPaid'] ?? 0)
        : int.tryParse(subscriptionDetails?['amountPaid']?.toString() ?? '0') ??
            0;
    final String startDate =
        subscriptionDetails?['startDate']?.toString() ?? '-';
    final String endDate = subscriptionDetails?['endDate']?.toString() ?? '-';
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final userData = userProvider.userData ?? {};
          final String userName = userProvider.userName;
          final String userLocation = userData['location'] ?? "";
          final String userExperience = userData['experience'] ?? "";
          final String userLanguages = userData['languages'] ?? "";
          final String profileImage =
              userData['profileImage'] ?? 'assets/dummyprofile.png';
          final int revaConnections = (userData['connections'] is List)
              ? (userData['connections'] as List).length
              : 0;
          final int pendingRequests = userData['pendingRequests'] ?? 0;
          final int pendingConnects = userData['pendingConnects'] ?? 0;
          final int achievementMax = 100;
          final int achievementProgress = userEvents.length;
          final int achievementCurrent = userEvents.length;
          final int nfcConnectionsLeft = userData['nfcConnectionsLeft'] ?? 0;
          return RefreshIndicator(
            onRefresh: () async {
              // Refresh all data when pulled
              await userProvider.refreshConnectionCounts();
              await fetchUserEvents();
              await fetchUpcomingEvents();
              await fetchMyPosts();
              await fetchPeopleYouMayKnow();
              await fetchSubscriptionStatus();
            },
            color: const Color(0xFF0262AB),
            backgroundColor: const Color(0xFF22252A),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(width * 0.05),
                child: Column(
                children: [
                  SizedBox(height: height * 0.045),
                  // Custom Top Navbar
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      Image.asset(
                        "assets/fulllogo.png",
                        height: width * 0.18,
                      ),
                      const Spacer(),
                      // Notification Icon with subtle glow and navigation
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/notification');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF23262B),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.07),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          // Removed padding from image
                          child: Image.asset(
                            "assets/bellicon.png",
                            height: width * 0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.025),
                  // Profile Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Image
                      CircleAvatar(
                        radius: width * 0.09,
                        backgroundImage: AssetImage(profileImage),
                      ),
                      SizedBox(width: width * 0.04),
                      // Hello & Name
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello!",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w400,
                              fontSize: width * 0.045,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "$userName,",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w700,
                              fontSize: width * 0.07,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Settings Menu Button (redirects to WalletScreen)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.settings,
                              color: Color(0xFF22252A)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const WalletScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.03),
                  // Search Bar & Filter Button
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: Container(
                  //         height: width * 0.13,
                  //         decoration: BoxDecoration(
                  //           color: const Color(0xFF2B2F34),
                  //           borderRadius: BorderRadius.circular(12),
                  //         ),
                  //         padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                  //         child: Row(
                  //           children: [
                  //             const Icon(Icons.search, color: Colors.white70, size: 22),
                  //             SizedBox(width: width * 0.02),
                  //             const Expanded(
                  //               child: TextField(
                  //                 style: TextStyle(color: Colors.white),
                  //                 cursorColor: Colors.white54,
                  //                 decoration: InputDecoration(
                  //                   hintText: 'Search ...',
                  //                   hintStyle: TextStyle(color: Colors.white54),
                  //                   border: InputBorder.none,
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //     SizedBox(width: width * 0.03),
                  //     // Filter Button
                  //     Container(
                  //       height: width * 0.13,
                  //       width: width * 0.13,
                  //       decoration: BoxDecoration(
                  //         gradient: const LinearGradient(
                  //           colors: [
                  //             Color(0xFF0262AB),
                  //             Color(0xFF01345A)
                  //           ],
                  //           begin: Alignment.topLeft,
                  //           end: Alignment.bottomRight,
                  //         ),
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //       child: IconButton(
                  //         icon: const Icon(Icons.filter_list, color: Colors.white, size: 26),
                  //         onPressed: () {
                  //           // TODO: Filter action
                  //         },
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(height: height * 0.03),
                  // Show cards based on userEvents length
                  if (isLoadingEvents)
                    const Center(child: CircularProgressIndicator())
                  else if (userEvents.length < 20)
                    BronzeCard(
                      name: userName,
                      location: userLocation,
                      experience: userExperience,
                      languages: userLanguages,
                      tag1: userData['tag1'] ?? "Commercial",
                      tag2: userData['tag2'] ?? "Plots",
                      tag3: userData['tag3'] ?? "Rental",
                      kycStatus: userData['kycStatus'] ?? "KYC Approved",
                    )
                  else if (userEvents.length >= 20 && userEvents.length < 60)
                    SilverCard(
                      name: userName,
                      location: userLocation,
                      experience: userExperience,
                      languages: userLanguages,
                      tag1: userData['tag1'] ?? "Commercial",
                      tag2: userData['tag2'] ?? "Plots",
                      tag3: userData['tag3'] ?? "Rental",
                      kycStatus: userData['kycStatus'] ?? "KYC Approved",
                    )
                  else if (userEvents.length >= 80)
                    GoldCard(
                      name: userName,
                      location: userLocation,
                      experience: userExperience,
                      languages: userLanguages,
                      tag1: userData['tag1'] ?? "Commercial",
                      tag2: userData['tag2'] ?? "Plots",
                      tag3: userData['tag3'] ?? "Rental",
                      kycStatus: userData['kycStatus'] ?? "KYC Approved",
                    ),
                  SizedBox(height: height * 0.02),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF01416A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.qr_code,
                          color: Colors.white, size: 22),
                      label: Text(
                        'View my Profile QR',
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () {
                        // Use phone number saved in UserProvider
                        String phone = UserProvider.userPhoneNumber ?? '';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileQrScreen(
                              mpin: '', // Do not show mpin
                              phone: phone,
                              name: userName,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  // Stats row (REVA Connections, Pending Requests, Pending Connects)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _customStatCard(
                          icon: Icons.people_alt,
                          label1: 'REVA',
                          label2: 'Connections',
                          value: revaConnections.toString(),
                          width: width,
                        ),
                      ),
                      SizedBox(width: width * 0.025),
                      Expanded(
                        child: _customStatCard(
                          icon: Icons.hourglass_empty,
                          label1: 'Incoming',
                          label2: 'Requests',
                          value: pendingRequests.toString(),
                          width: width,
                        ),
                      ),
                      SizedBox(width: width * 0.025),
                      Expanded(
                        child: _customStatCard(
                          icon: Icons.link,
                          label1: 'Outgoing',
                          label2: 'Requests',
                          value: pendingConnects.toString(),
                          width: width,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.04),
                  // Dynamic Progress bar section
                  _DynamicProgressBar(
                    progress: achievementProgress,
                    max: achievementMax,
                    tickPositions: [0, achievementCurrent, achievementMax],
                    label: 'Your progress',
                    unlockText: 'to Unlock',
                    unlockCard: 'Gold card',
                    width: width,
                  ),
                  SizedBox(height: height * 0.01),
                  // Events Attended Progress
                  Row(
                    children: [
                      Icon(Icons.event_available,
                          color: Colors.white70, size: 22),
                      const SizedBox(width: 8),
                      Text('Events Attended:',
                          style: GoogleFonts.dmSans(
                              color: Colors.white70, fontSize: 15)),
                      const SizedBox(width: 8),
                      Text(userEvents.length.toString(),
                          style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: height * 0.05),
                  // Upcoming Events Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Upcoming Events',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  if (isLoadingUpcomingEvents)
                    const Center(child: CircularProgressIndicator())
                  else
                    _UpcomingEventsCarousel(
                      events: upcomingEvents
                          .map((event) => {
                                'image': event['image'] ??
                                    'assets/eventdummyimage.png',
                                'price': event['price'] ?? '',
                                'title': event['title'] ?? '',
                                'location': event['location'] ?? '',
                                'registered': event['registered'] ?? 0,
                              })
                          .toList(),
                    ),
                  const SizedBox(height: 10),
                  // Page indicator is inside the carousel
                  SizedBox(height: height * 0.04),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF01416A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EventScreen()),
                        );
                      },
                      child: Text(
                        'Explore All Events',
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward,
                      color: Colors.white, size: height * 0.045),

                  // People you may know section
                  SizedBox(height: height * 0.04),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'People you may know',
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const PeopleYouMayKnow()),
                            );
                          },
                          child: Text('See all',
                              style: GoogleFonts.dmSans(
                                  color: const Color(0xFFB2C2D9),
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  if (isLoadingPeople)
                    const Center(child: CircularProgressIndicator())
                  else
                    SizedBox(
                      height: width * 0.52,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: peopleYouMayKnow.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(width: width * 0.04),
                        itemBuilder: (context, index) {
                          final person = peopleYouMayKnow[index];
                          return SizedBox(
                            width: width * 0.42,
                            child: PeopleYouMayKnowCard(
                              name: person['fullName'] ??
                                  person['name'] ??
                                  'Unknown',
                              image: person['profile'] ??
                                  person['image'] ??
                                  'assets/dummyprofile.png',
                              userId: person['userId'] ??
                                  '', // Pass userId as required
                              // Add more fields as needed
                            ),
                          );
                        },
                      ),
                    ),
                  SizedBox(height: height * 0.03),
                  // Create Post Card Section (dynamic)
                  CreatePostCard(
                    usedPosts: myPosts.length,
                    maxPosts: 2, // If you have a max from API, use it here
                    onCreatePost: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const FractionallySizedBox(
                          heightFactor: 0.98,
                          child: SharePostScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  // Contact Management Section
                  ContactManagementSection(
                    contacts: [
                      ContactCardData(
                          icon: Image.asset('assets/builder.png', width: 28),
                          count: userData['builderCount']?.toString() ?? '0',
                          label: 'Builder',
                          userId: userData['id'] ?? ''),
                      ContactCardData(
                          icon: Image.asset('assets/loan.png', width: 28),
                          count:
                              userData['loanProviderCount']?.toString() ?? '0',
                          label: 'Loan Provider',
                          userId: userData['id'] ?? ''),
                      ContactCardData(
                          icon: Image.asset('assets/interior.png', width: 28),
                          count:
                              userData['interiorDesignerCount']?.toString() ??
                                  '0',
                          label: 'Interior Designer',
                          userId: userData['id'] ?? ''),
                      ContactCardData(
                          icon: Image.asset('assets/material.png', width: 28),
                          count:
                              userData['materialSupplierCount']?.toString() ??
                                  '0',
                          label: 'Material Supplier',
                          userId: userData['id'] ?? ''),
                      ContactCardData(
                          icon: Image.asset('assets/legal.png', width: 28),
                          count:
                              userData['legalAdvisorCount']?.toString() ?? '0',
                          label: 'Legal Advisor',
                          userId: userData['id'] ?? ''),
                      ContactCardData(
                          icon: Image.asset('assets/vastu.png', width: 28),
                          count: userData['vastuConsultantCount']?.toString() ??
                              '0',
                          label: 'Vastu Consultant',
                          userId: userData['id'] ?? ''),
                      ContactCardData(
                          icon: Image.asset('assets/homebuyer.png', width: 28),
                          count: userData['homeBuyerCount']?.toString() ?? '0',
                          label: 'Home Buyer',
                          userId: userData['id'] ?? ''),
                      ContactCardData(
                          icon: Image.asset('assets/investor.png', width: 28),
                          count:
                              userData['propertyInvestorCount']?.toString() ??
                                  '0',
                          label: 'Property Investor',
                          userId: userData['id'] ?? ''),
                    ],
                    achievement: AchievementData(
                      progress: achievementProgress,
                      max: achievementMax,
                      current: achievementCurrent,
                      label: 'Achievement',
                      subtitle: 'unlock a gift on you 100th attend event',
                    ),
                    nfcCard: NfcCardData(
                      title: 'NFC Card',
                      subtitle: 'Tap to claim your NFC card',
                      connectionsLeft: nfcConnectionsLeft,
                      onClaim: () {},
                      onBuy: () {},
                    ),
                    subscription: SubscriptionStatusData(
                      active: subscriptionActive,
                      daysLeft: subscriptionDaysLeft,
                      onRenew: () {},
                      plan: plan,
                      amountPaid: amountPaid,
                      startDate: startDate,
                      endDate: endDate,
                    ),
                  ),
                ],
              ),
            ),
          ),
          );
        },
      ),
    );
  }

  // Custom stat card to match Figma design
  Widget _customStatCard({
    required IconData icon,
    required String label1,
    required String label2,
    required String value,
    required double width,
  }) {
    // Responsive sizing
    final double cardWidth = width * 0.28;
    final double cardHeight = cardWidth * 0.7;
    final double iconSize = cardWidth * 0.18;
    final double iconCircle = cardWidth * 0.28;
    final double valueFont = cardWidth * 0.20;
    final double labelFont = cardWidth * 0.085;
    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: const EdgeInsets.only(right: 0),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3339),
        borderRadius: BorderRadius.circular(cardWidth * 0.16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: cardWidth * 0.06, vertical: cardHeight * 0.045),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: iconCircle,
                  height: iconCircle,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22252A),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(icon,
                        color: const Color(0xFFBDBDBD), size: iconSize),
                  ),
                ),
                SizedBox(width: cardWidth * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label1,
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: labelFont,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        label2,
                        style: GoogleFonts.dmSans(
                          color: Colors.white.withOpacity(0.62),
                          fontSize: labelFont,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Removed SizedBox, use only spaceBetween
            Center(
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontSize: valueFont,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ...existing code...
}

// Dynamic Progress Bar Widget
class _DynamicProgressBar extends StatelessWidget {
  final int progress;
  final int max;
  final List<int> tickPositions;
  final String label;
  final String unlockText;
  final String unlockCard;
  final double width;

  const _DynamicProgressBar({
    required this.progress,
    required this.max,
    required this.tickPositions,
    required this.label,
    required this.unlockText,
    required this.unlockCard,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    // Removed unused barWidth and barHeight
    double progressPercent = (progress / max).clamp(0.0, 1.0);
    // Ensure at least a small visible bar for 1 event
    if (progress > 0 && progressPercent < 0.04) {
      progressPercent = 0.04;
    }
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: width * 0.005),
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.03, vertical: width * 0.025),
      decoration: BoxDecoration(
        color: const Color(0xFF292B32),
        borderRadius: BorderRadius.circular(width * 0.03),
        border: Border.all(color: const Color(0xFF0269B6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w400,
                  fontSize: width * 0.028,
                ),
              ),
              const Spacer(),
              Container(
                width: width * 0.08,
                height: width * 0.08,
                decoration: const BoxDecoration(
                  color: Color(0xFF22252A),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(Icons.lock,
                      color: Colors.amber[200], size: width * 0.045),
                ),
              ),
            ],
          ),
          SizedBox(height: width * 0.012),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${((progress / max) * 100).round()}%',
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.048,
                ),
              ),
              SizedBox(width: width * 0.01),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: unlockText,
                        style: GoogleFonts.dmSans(
                          color: const Color(0xFF0269B6),
                          fontWeight: FontWeight.bold,
                          fontSize: width * 0.048,
                        ),
                      ),
                      TextSpan(
                        text: ' ',
                        style: GoogleFonts.dmSans(
                          color: const Color(0xFF0072C3),
                          fontWeight: FontWeight.bold,
                          fontSize: width * 0.048,
                        ),
                      ),
                      TextSpan(
                        text: unlockCard,
                        style: GoogleFonts.dmSans(
                          color: const Color.fromARGB(255, 188, 198, 6),
                          fontWeight: FontWeight.bold,
                          fontSize: width * 0.048,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: width * 0.018),
          // Progress bar with ticks
          LayoutBuilder(
            builder: (context, constraints) {
              final barHeight = width * 0.022;
              final tickSize = width * 0.015;
              final barWidth = constraints.maxWidth;
              // 4 dots at 20, 40, 60, 80 percent
              final List<int> ticks = [20, 40, 60, 80];
              List<double> tickOffsets =
                  ticks.map((tick) => (tick / 100) * barWidth).toList();
              return Stack(
                children: [
                  // Background bar
                  Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(width * 0.08),
                    ),
                  ),
                  // Foreground (progress) bar
                  Container(
                    width: barWidth * progressPercent,
                    height: barHeight,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF0269B6), Color(0xFF002E50)],
                      ),
                      borderRadius: BorderRadius.circular(width * 0.08),
                    ),
                  ),
                  // Ticks
                  ...List.generate(ticks.length, (i) {
                    final isOnBlue =
                        tickOffsets[i] <= barWidth * progressPercent;
                    return Positioned(
                      left: tickOffsets[i] - tickSize / 2,
                      top: (barHeight - tickSize) / 2,
                      child: Container(
                        width: tickSize,
                        height: tickSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOnBlue
                              ? const Color(0xFFEDF5FF)
                              : const Color(0xFF0269B6),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
          SizedBox(height: width * 0.012),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0',
                  style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: width * 0.025,
                      fontWeight: FontWeight.w600)),
              Text('$progress',
                  style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: width * 0.03,
                      fontWeight: FontWeight.w600)),
              Text('$max',
                  style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: width * 0.025,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

// Upcoming Events Carousel Widget
class _UpcomingEventsCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> events;
  const _UpcomingEventsCarousel({required this.events});

  @override
  State<_UpcomingEventsCarousel> createState() =>
      _UpcomingEventsCarouselState();
}

class _UpcomingEventsCarouselState extends State<_UpcomingEventsCarousel> {
  int _currentPage = 0;
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.95);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.width;
    return Column(
      children: [
        SizedBox(
          height: height * 0.6,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.events.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) {
              final event = widget.events[i];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: width * 0.01),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(event['image']),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Gradient overlay for text readability
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Event info
                    Positioned(
                      left: width * 0.04,
                      bottom: width * 0.04,
                      right: width * 0.04,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  event['price'],
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: height * 0.07,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  event['title'],
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: height * 0.045,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${event['registered']} people have already registered',
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white70,
                                    fontSize: height * 0.032,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: width * 0.02),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF01416A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.06,
                                vertical: width * 0.025,
                              ),
                            ),
                            onPressed: () {
                              // Pass the actual event title as eventId to EventDetailScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventDetailScreen(
                                      eventId: event['title'] ?? ''),
                                ),
                              );
                            },
                            child: Text(
                              'Book Now',
                              style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: height * 0.035,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Page indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.events.length,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == i ? 10 : 7,
              height: _currentPage == i ? 10 : 7,
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? const Color(0xFF1976D2)
                    : Colors.white24,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
