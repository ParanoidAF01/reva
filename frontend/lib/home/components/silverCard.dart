import 'package:flutter/material.dart';

class SilverCard extends StatelessWidget {
  final String name;
  final String location;
  final String experience;
  final String languages;
  final String tag1;
  final String tag2;
  final String tag3;
  final String kycStatus;
  final double tagSpacing;
  final double kycGap;
  const SilverCard({
    super.key,
    required this.name,
    required this.location,
    required this.experience,
    required this.languages,
    required this.tag1,
    required this.tag2,
    required this.tag3,
    required this.kycStatus,
    this.tagSpacing = 2.0,
    this.kycGap = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          width: screenWidth - 32, // 16px margin on each side, adjust as needed
          height: 200,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1.53, color: Colors.white),
              borderRadius: BorderRadius.circular(12.25),
            ),
          ),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.asset(
                  'assets/silver_background.png',
                  fit: BoxFit.cover,
                ),
              ),
              // Medal image (bigger and more centered)
              Positioned(
                right: 50,
                top: 20,
                child: Image.asset(
                  'assets/silver_medal.png',
                  width: 90,
                  height: 90,
                ),
              ),
              // Name
              Positioned(
                left: 23.47,
                top: 20,
                child: SizedBox(
                  width: 168,
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w700,
                      height: 1.40,
                    ),
                  ),
                ),
              ),
              // Location
              Positioned(
                left: 23.47,
                top: 48,
                child: SizedBox(
                  width: 168,
                  child: Text(
                    location,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w700,
                      height: 1.40,
                    ),
                  ),
                ),
              ),
              // Experience
              Positioned(
                left: 111,
                top: 109,
                child: SizedBox(
                  width: 50,
                  child: Text(
                    experience,
                    style: const TextStyle(
                      color: Color(0xFFBDBDBD),
                      fontSize: 12,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w400,
                      height: 1.40,
                    ),
                  ),
                ),
              ),
              // Languages
              Positioned(
                left: 23,
                top: 109,
                child: SizedBox(
                  width: 168,
                  child: Text(
                    (languages.isNotEmpty) ? languages : 'Languages not set',
                    style: const TextStyle(
                      color: Color(0xFFBDBDBD),
                      fontSize: 12,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w400,
                      height: 1.40,
                    ),
                  ),
                ),
              ),
              // Tags and KYC status in a single row (only if present)
              if ((tag1.isNotEmpty || tag2.isNotEmpty || tag3.isNotEmpty || kycStatus.isNotEmpty))
                Positioned(
                  left: 15,
                  top: 139,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (tag1.isNotEmpty) _tagChip(tag1),
                      if (tag1.isNotEmpty && (tag2.isNotEmpty || tag3.isNotEmpty)) SizedBox(width: tagSpacing),
                      if (tag2.isNotEmpty) _tagChip(tag2),
                      if (tag2.isNotEmpty && tag3.isNotEmpty) SizedBox(width: tagSpacing),
                      if (tag3.isNotEmpty) _tagChip(tag3),
                      if ((tag1.isNotEmpty || tag2.isNotEmpty || tag3.isNotEmpty) && kycStatus.isNotEmpty) SizedBox(width: kycGap),
                      if (kycStatus.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check, color: Colors.green, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              kycStatus,
                              style: const TextStyle(
                                color: Color(0xFFBDBDBD),
                                fontSize: 12,
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w400,
                                height: 1.40,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _tagChip(String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFF2B2F34),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontFamily: 'DM Sans',
        fontWeight: FontWeight.w400,
        height: 1.40,
      ),
    ),
  );
}
