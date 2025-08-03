import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactManagementSection extends StatelessWidget {
  final List<ContactCardData> contacts;
  final AchievementData achievement;
  final NfcCardData nfcCard;
  final SubscriptionStatusData subscription;
  // Adjustable sizes
  final double tileIconScale;
  final double tileCountFontScale;
  final double tileLabelFontScale;
  final double tilePaddingScale;
  final double tileRadiusScale;
  const ContactManagementSection({
    super.key,
    required this.contacts,
    required this.achievement,
    required this.nfcCard,
    required this.subscription,
    this.tileIconScale = 1.5,
    this.tileCountFontScale = 0.8,
    this.tileLabelFontScale = 0.8,
    this.tilePaddingScale = 0.8,
    this.tileRadiusScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = const Color(0xFF23262B);
    final labelStyle = GoogleFonts.dmSans(
      color: Colors.white,
      fontWeight: FontWeight.w500,
      fontSize: 10,
    );
    final countStyle = GoogleFonts.dmSans(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: 15,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contact Management', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 22, color: Colors.white)),
        const SizedBox(height: 2),
        Text('All your Contacts in one place', style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 18),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: contacts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            childAspectRatio: 0.55, // Wider and taller tiles
          ),
          itemBuilder: (context, i) {
            final c = contacts[i];
            return LayoutBuilder(
              builder: (context, constraints) {
                final double borderRadius = 22 * tileRadiusScale;
                final double tileWidth = constraints.maxWidth * 0.95; // Make background wider
                final double tileHeight = constraints.maxHeight * 1.18; // Make background taller
                final double iconSize = tileHeight * 0.20 * tileIconScale;
                final double countFont = tileHeight * 0.18 * tileCountFontScale;
                final double labelFont = tileHeight * 0.11 * tileLabelFontScale;
                final double avatarTop = -iconSize * 0.12; // less overlap, closer to content
                return Center(
                  child: SizedBox(
                    width: tileWidth,
                    height: tileHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        image: const DecorationImage(
                          image: AssetImage('assets/contactmanagement_tile.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: tileHeight * 0.06),
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.13),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.10), width: 1.2 * tilePaddingScale),
                            ),
                            child: Center(child: SizedBox(width: iconSize * 0.7, height: iconSize * 0.7, child: c.icon)),
                          ),
                          SizedBox(height: tileHeight * 0.02),
                          Text(
                            c.count,
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: countFont,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: tileHeight * 0.005 * tilePaddingScale),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Text(
                              c.label,
                              style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: labelFont,
                                height: 1.13,
                                letterSpacing: 0.01,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // ...existing code for any additional content...
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 24),
        AchievementCard(data: achievement),
        const SizedBox(height: 18),
        NfcCardWidget(data: nfcCard),
        const SizedBox(height: 32),
        SubscriptionStatusCard(data: subscription),
      ],
    );
  }
}

class ContactCardData {
  final Widget icon;
  final String count;
  final String label;
  ContactCardData({required this.icon, required this.count, required this.label});
}

class AchievementData {
  final int progress;
  final int max;
  final int current;
  final String label;
  final String subtitle;
  AchievementData({required this.progress, required this.max, required this.current, required this.label, required this.subtitle});
}

class NfcCardData {
  final String title;
  final String subtitle;
  final int connectionsLeft;
  final VoidCallback onClaim;
  final VoidCallback onBuy;
  NfcCardData({required this.title, required this.subtitle, required this.connectionsLeft, required this.onClaim, required this.onBuy});
}

class SubscriptionStatusData {
  final bool active;
  final int daysLeft;
  final VoidCallback onRenew;
  SubscriptionStatusData({required this.active, required this.daysLeft, required this.onRenew});
}

class AchievementCard extends StatelessWidget {
  final AchievementData data;
  const AchievementCard({super.key, required this.data});
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    double progressPercent = data.progress / data.max;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF23262B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24.withOpacity(0.18), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(data.label, style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white)),
              Icon(Icons.celebration, color: Colors.amber[200], size: 22),
            ],
          ),
          const SizedBox(height: 2),
          Text(data.subtitle, style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 18),
          Row(
            children: [
              Text('0', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 13)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.blue[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progressPercent,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      Positioned(
                        left: (width - 80) * progressPercent,
                        child: Icon(Icons.location_on, color: Colors.red, size: 18),
                      ),
                      Positioned(
                        right: 0,
                        child: Icon(Icons.card_giftcard, color: Colors.amber, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
              Text('${data.max}', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0', style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 12)),
              Text('${data.progress}', style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 12)),
              Text('${data.max}', style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class NfcCardWidget extends StatelessWidget {
  final NfcCardData data;
  const NfcCardWidget({super.key, required this.data});
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF23262B),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white24.withOpacity(0.18), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(data.title, style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white)),
                  GestureDetector(
                    onTap: data.onBuy,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF23262B),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text('Buy?', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 13)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(data.subtitle, style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: 'You are ',
                  style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
                  children: [
                    TextSpan(
                      text: data.connectionsLeft.toString(),
                      style: GoogleFonts.dmSans(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    TextSpan(
                      text: ' connections away to claim it.',
                      style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32), // Add more space for button overlap
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: -24,
          child: Center(
            child: ElevatedButton.icon(
              onPressed: data.onClaim,
              icon: const Icon(Icons.lock, color: Colors.white, size: 18),
              label: Text('Claim now', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF01416A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.18),
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SubscriptionStatusCard extends StatelessWidget {
  final SubscriptionStatusData data;
  const SubscriptionStatusCard({super.key, required this.data});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF23262B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24.withOpacity(0.18), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Subscription Status', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white)),
              const SizedBox(width: 8),
              Icon(Icons.circle, color: data.active ? Colors.greenAccent : Colors.red, size: 12),
              const SizedBox(width: 2),
              Text(data.active ? 'Active' : 'Inactive', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              text: '${data.daysLeft}',
              style: GoogleFonts.dmSans(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 28),
              children: [
                TextSpan(
                  text: ' days left',
                  style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text('Your subscription is expiring soon.\nRenew to keep accessing all features.', style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: data.onRenew,
              child: Text('Renew Now', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF01416A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
