import 'package:flutter/material.dart';

class GoldCard extends StatelessWidget {
  final String name;
  final String location;
  final String experience;
  final String language;
  final String tag1;
  final String tag2;
  final String kycStatus;
  final double tagSpacing;
  final double kycGap;
  GoldCard({
    super.key,
    required this.name,
    required this.location,
    required this.experience,
    required this.language,
    required this.tag1,
    required this.tag2,
    String? kycStatus,
    this.tagSpacing = 2.0,
    this.kycGap = 30.0,
  }) : kycStatus = (kycStatus != null && kycStatus.isNotEmpty) ? kycStatus : 'KYC Not Verified';

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
                  'assets/Gold_background.png',
                  fit: BoxFit.cover,
                ),
              ),
              // Medal image (bigger and more centered)
              Positioned(
                right: 50,
                top: 20,
                child: Image.asset(
                  'assets/Gold_medal.png',
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
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
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
              // Experience (always shown)
              Positioned(
                left: 23,
                top: 109,
                child: SizedBox(
                  width: 168,
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
              // Language (only if present, below experience)
              if (language.isNotEmpty)
                Positioned(
                  left: 23,
                  top: 129,
                  child: SizedBox(
                    width: 168,
                    child: Text(
                      language,
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
              // KYC approved (right-aligned, new line)
              if (kycStatus.isNotEmpty)
                Positioned(
                  right: 23,
                  top: language.isNotEmpty ? 149 : 129,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        kycStatus.toLowerCase() == 'verified' ? Icons.check_circle : Icons.cancel,
                        color: kycStatus.toLowerCase() == 'verified' ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        kycStatus.toLowerCase() == 'verified' ? 'KYC Verified' : 'KYC Not Verified',
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
                ),
              // Tags row (below experience/languages)
              if (tag1.isNotEmpty || tag2.isNotEmpty)
                Positioned(
                  left: 15,
                  top: language.isNotEmpty ? 155 : 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (tag1.isNotEmpty) _tagChip(tag1),
                      if (tag1.isNotEmpty && tag2.isNotEmpty) SizedBox(width: tagSpacing),
                      if (tag2.isNotEmpty) _tagChip(tag2),
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
