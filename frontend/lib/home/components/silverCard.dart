import 'package:flutter/material.dart';

class SilverCard extends StatelessWidget {
  const SilverCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E323A),
            Color(0xFF1F2227),
            Color(0xFF2C2E35),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          /// Top Right Edit Icon
          const Positioned(
            top: 0,
            right: 0,
            child: Icon(Icons.edit, color: Colors.white, size: 18),
          ),

          /// Main Row Layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Left Profile Image Placeholder
              Container(
                height: 64,
                width: 64,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(12),
                  // TODO: Replace with your actual image
                  image: const DecorationImage(
                    image: AssetImage('assets/your_image.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              /// Profile Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ayush Kumar.",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Delhi NCR",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    /// Language and Experience
                    Row(
                      children: const [
                        _FadedText("Hindi, English"),
                        SizedBox(width: 16),
                        _FadedText("4+ years"),
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// Tags Row
                    Row(
                      children: const [
                        _GlassChip(label: "Commercial"),
                        SizedBox(width: 8),
                        _GlassChip(label: "Plots"),
                        SizedBox(width: 8),
                        _GlassChip(label: "Rental"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          /// KYC Approved
          const Positioned(
            right: 0,
            bottom: 0,
            child: Row(
              children: [
                Icon(Icons.check, color: Colors.greenAccent, size: 16),
                SizedBox(width: 4),
                Text(
                  "KYC\napproved",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable faded text
class _FadedText extends StatelessWidget {
  final String text;
  const _FadedText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

/// Glass chip with gradient
class _GlassChip extends StatelessWidget {
  final String label;
  const _GlassChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF7B7E83), Color(0xFF2E2F31)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.black26),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
