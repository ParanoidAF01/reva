import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reva/home/components/GoldCard.dart';
import 'package:reva/home/create_post_card.dart';
import 'package:reva/peopleyoumayknow/peopleyoumayknow.dart';
import 'package:reva/peopleyoumayknow/peopleyoumayknowtile.dart';
import 'package:reva/home/contact_management_section.dart';
import 'package:reva/qr/profile_qr_screen.dart';
import 'package:reva/events/event_detail_screen.dart';
import 'package:reva/events/eventscreen.dart';
import 'package:reva/posts/createpost.dart';
import 'package:reva/providers/user_provider.dart';

// Make sure the GoldCard widget is defined in GoldCard.dart
// import 'package:reva/qr/profile_qr_screen.dart';
// Make sure ProfileQrScreen is a widget class in this file.

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: SingleChildScrollView(
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
                    backgroundImage: AssetImage('assets/dummyprofile.png'),
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
                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          return Text(
                            "${userProvider.userName},",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w700,
                              fontSize: width * 0.07,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Edit Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF22252A)),
                      onPressed: () {
                        // TODO: Edit profile action
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.03),
              // Search Bar & Filter Button
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: width * 0.13,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B2F34),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                      child: Row(
                        children: [
                          const Icon(Icons.search,
                              color: Colors.white70, size: 22),
                          SizedBox(width: width * 0.02),
                          const Expanded(
                            child: TextField(
                              style: TextStyle(color: Colors.white),
                              cursorColor: Colors.white54,
                              decoration: InputDecoration(
                                hintText: 'Search ...',
                                hintStyle: TextStyle(color: Colors.white54),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: width * 0.03),
                  // Filter Button
                  Container(
                    height: width * 0.13,
                    width: width * 0.13,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0262AB), Color(0xFF01345A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list,
                          color: Colors.white, size: 26),
                      onPressed: () {
                        // TODO: Filter action
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.03),
              // Example dynamic data for GoldCard
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final String userName = userProvider.userName;
                  final String userLocation =
                      userProvider.userData?['location'] ?? "Delhi NCR";
                  final String userExperience =
                      userProvider.userData?['experience'] ?? "4+ years";
                  final String userLanguages =
                      userProvider.userData?['languages'] ?? "Hindi, English";
                  final String tag1 = "Commercial";
                  final String tag2 = "Plots";
                  final String tag3 = "Rental";
                  final String kycStatus = "KYC Approved";
                  return Column(
                    children: [
                      GoldCard(
                        name: userName,
                        location: userLocation,
                        experience: userExperience,
                        languages: userLanguages,
                        tag1: tag1,
                        tag2: tag2,
                        tag3: tag3,
                        kycStatus: kycStatus,
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
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: Icon(Icons.qr_code,
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileQrScreen(
                                  mpin: '1234', // Replace with real user data
                                  phone:
                                      '9876543210', // Replace with real user data
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
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
                      value: '384',
                      width: width,
                    ),
                  ),
                  SizedBox(width: width * 0.025),
                  Expanded(
                    child: _customStatCard(
                      icon: Icons.hourglass_empty,
                      label1: 'Pending',
                      label2: 'Requests',
                      value: '40',
                      width: width,
                    ),
                  ),
                  SizedBox(width: width * 0.025),
                  Expanded(
                    child: _customStatCard(
                      icon: Icons.link,
                      label1: 'Pending',
                      label2: 'Connects',
                      value: '3',
                      width: width,
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.04),
              // Dynamic Progress bar section
              _DynamicProgressBar(
                progress: 196,
                max: 500,
                tickPositions: const [0, 196, 500],
                label: 'Your progress',
                unlockText: 'to Unlock',
                unlockCard: 'Silver card',
                width: width,
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
              _UpcomingEventsCarousel(
                events: [
                  {
                    'image': 'assets/eventdummyimage.png',
                    'price': '₹599',
                    'title': 'Mumbai Realty Connect',
                    'location': 'Mumbai',
                    'registered': 108,
                  },
                  // Add more events here as needed
                ],
              ),
              SizedBox(height: 10),
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
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EventScreen()),
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
              // Upcoming Events Section

              SizedBox(width: 8),
              Icon(Icons.arrow_forward,
                  color: Colors.white, size: height * 0.045),

              // People you may know section (placeholder for now)
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
                              builder: (context) => PeopleYouMayKnow()),
                        );
                      },
                      child: Text('See all',
                          style: GoogleFonts.dmSans(
                              color: Color(0xFFB2C2D9),
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.02),
              // Use responsive PeopleYouMayKnowCard and ensure no vertical overflow
              SizedBox(
                height: width * 0.52, // Responsive height based on width
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5, // Example count, replace with dynamic data
                  separatorBuilder: (context, index) =>
                      SizedBox(width: width * 0.04),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: width * 0.42, // Responsive width for card
                      child: const PeopleYouMayKnowCard(),
                    );
                  },
                ),
              ),
              SizedBox(height: height * 0.03),
              // Create Post Card Section (dynamic)
              CreatePostCard(
                usedPosts: 0, // Replace with your dynamic value
                maxPosts: 2, // Replace with your dynamic value
                onCreatePost: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => FractionallySizedBox(
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
                      count: '48',
                      label: 'Builder'),
                  ContactCardData(
                      icon: Image.asset('assets/loan.png', width: 28),
                      count: '12',
                      label: 'Loan Provider'),
                  ContactCardData(
                      icon: Image.asset('assets/interior.png', width: 28),
                      count: '11',
                      label: 'Interior Designer'),
                  ContactCardData(
                      icon: Image.asset('assets/material.png', width: 28),
                      count: '30',
                      label: 'Material Supplier'),
                  ContactCardData(
                      icon: Image.asset('assets/legal.png', width: 28),
                      count: '48',
                      label: 'Legal Advisor'),
                  ContactCardData(
                      icon: Image.asset('assets/vastu.png', width: 28),
                      count: '12',
                      label: 'Vastu Consultant'),
                  ContactCardData(
                      icon: Image.asset('assets/homebuyer.png', width: 28),
                      count: '11',
                      label: 'Home Buyer'),
                  ContactCardData(
                      icon: Image.asset('assets/investor.png', width: 28),
                      count: '30',
                      label: 'Property Investor'),
                ],
                achievement: AchievementData(
                  progress: 32,
                  max: 100,
                  current: 32,
                  label: 'Achievement',
                  subtitle: 'unlock a gift on you 100th attend event',
                ),
                nfcCard: NfcCardData(
                  title: 'Want NFC Card?',
                  subtitle: 'unlock your premium silver NFC Card.',
                  connectionsLeft: 406,
                  onClaim: () {},
                  onBuy: () {},
                ),
                subscription: SubscriptionStatusData(
                  active: true,
                  daysLeft: 29,
                  onRenew: () {},
                ),
              ),
            ],
          ),
        ),
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
      margin: EdgeInsets.only(right: 0),
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
                  decoration: BoxDecoration(
                    color: const Color(0xFF22252A),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(icon, color: Color(0xFFBDBDBD), size: iconSize),
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

  // Tick dot for progress bar
// Tick dot for progress bar with adjustable size and color
  Widget _tickDot({bool gradient = false, double size = 5}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: gradient ? Color(0xFF0269B6) : Color(0xFFEDF5FF),
        gradient: gradient
            ? LinearGradient(
                colors: [Color(0xFF0269B6), Color(0xFF002E50)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
      ),
    );
  }
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
    Key? key,
    required this.progress,
    required this.max,
    required this.tickPositions,
    required this.label,
    required this.unlockText,
    required this.unlockCard,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double barWidth = width;
    double barHeight = 18;
    double progressPercent = progress / max;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: width * 0.005),
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.03, vertical: width * 0.025),
      decoration: BoxDecoration(
        color: const Color(0xFF292B32),
        borderRadius: BorderRadius.circular(width * 0.03),
        border: Border.all(color: Color(0xFF0269B6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 2),
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
              Spacer(),
              Container(
                width: width * 0.08,
                height: width * 0.08,
                decoration: BoxDecoration(
                  color: const Color(0xFF22252A),
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
                          color: Color(0xFF0269B6),
                          fontWeight: FontWeight.bold,
                          fontSize: width * 0.048,
                        ),
                      ),
                      TextSpan(
                        text: ' ',
                        style: GoogleFonts.dmSans(
                          color: Color(0xFF0072C3),
                          fontWeight: FontWeight.bold,
                          fontSize: width * 0.048,
                        ),
                      ),
                      TextSpan(
                        text: unlockCard,
                        style: GoogleFonts.dmSans(
                          color: Color(0xFF999999),
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
                      color: Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(width * 0.08),
                    ),
                  ),
                  // Foreground (progress) bar
                  Container(
                    width: barWidth * progressPercent,
                    height: barHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
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
                          color:
                              isOnBlue ? Color(0xFFEDF5FF) : Color(0xFF0269B6),
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
  const _UpcomingEventsCarousel({Key? key, required this.events})
      : super(key: key);

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
                      offset: Offset(0, 6),
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
                                SizedBox(height: 2),
                                Text(
                                  event['title'],
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: height * 0.045,
                                  ),
                                ),
                                SizedBox(height: 2),
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
                              // Navigate to event detail page with a sample eventId (replace with real id if available)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EventDetailScreen(eventId: '1'),
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
        SizedBox(height: 10),
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
