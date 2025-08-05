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
    this.tileCountFontScale = 0.4,
    this.tileLabelFontScale = 0.7,
    this.tilePaddingScale = 0.8,
    this.tileRadiusScale = 1,
  });

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFF23262B);
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
            childAspectRatio: 0.55,
          ),
          itemBuilder: (context, i) {
            final c = contacts[i];
            return LayoutBuilder(
              builder: (context, constraints) {
                final double borderRadius = 22 * tileRadiusScale;
                final double tileWidth = constraints.maxWidth * 0.9;
                final double tileHeight = constraints.maxHeight * 1.0; // Use full height per tile
                final double iconSize = tileHeight * 0.20 * tileIconScale;
                final double countFont = tileHeight * 0.18 * tileCountFontScale;
                final double labelFont = tileHeight * 0.11 * tileLabelFontScale;
                final double avatarTop = -iconSize * 0.12;
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
        // SubscriptionStatusCard(data: subscription),
      ],
    );
  }
}

class ContactCardData {
  final Widget icon;
  final String count;
  final String label;
  final String userId;
  ContactCardData({required this.icon, required this.count, required this.label, required this.userId});
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
  final String plan;
  final int amountPaid;
  final String startDate;
  final String endDate;
  final VoidCallback onRenew;
  SubscriptionStatusData({
    required this.active,
    required this.daysLeft,
    required this.plan,
    required this.amountPaid,
    required this.startDate,
    required this.endDate,
    required this.onRenew,
  });
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
                        child: const Icon(Icons.location_on, color: Colors.red, size: 18),
                      ),
                      const Positioned(
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
    final requiredConnections = 500;
    final achievementUnlocked = data.connectionsLeft >= requiredConnections;
    final remainingConnections = achievementUnlocked ? 0 : (requiredConnections - data.connectionsLeft);
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
              Text(data.title, style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: achievementUnlocked ? Colors.grey : const Color(0xFF23262B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  achievementUnlocked ? 'Claimed' : 'Claim now',
                  style: GoogleFonts.dmSans(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(data.subtitle, style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              text: achievementUnlocked ? 'Achievement unlocked!' : 'You need ',
              style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
              children: achievementUnlocked
                  ? []
                  : [
                      TextSpan(
                        text: remainingConnections.toString(),
                        style: GoogleFonts.dmSans(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                      TextSpan(
                        text: ' more connections to unlock achievement.',
                        style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}
