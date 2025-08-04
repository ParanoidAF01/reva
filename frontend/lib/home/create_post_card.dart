import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreatePostCard extends StatelessWidget {
  final int usedPosts;
  final int maxPosts;
  final VoidCallback onCreatePost;
  const CreatePostCard({
    super.key,
    required this.usedPosts,
    required this.maxPosts,
    required this.onCreatePost,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(top: width * 0.04),
      padding: EdgeInsets.all(width * 0.045),
      decoration: BoxDecoration(
        color: const Color(0xFF363940),
        borderRadius: BorderRadius.circular(width * 0.045),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create a Post?',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: width * 0.055,
                      ),
                    ),
                    SizedBox(height: width * 0.01),
                    Text(
                      'Post buyer/seller/investor needs',
                      style: GoogleFonts.dmSans(
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                        fontSize: width * 0.032,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF22252A),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(width * 0.025),
                    child: Icon(Icons.push_pin, color: const Color(0xFFE74C3C), size: width * 0.06),
                  ),
                  SizedBox(height: width * 0.01),
                  Text(
                    '$usedPosts/$maxPosts used',
                    style: GoogleFonts.dmSans(
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                      fontSize: width * 0.032,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: width * 0.045),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF01416A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: width * 0.04),
              ),
              onPressed: onCreatePost,
              child: Text(
                '+ Create General Post',
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: width * 0.045,
                ),
              ),
            ),
          ),
          SizedBox(height: width * 0.02),
          Text(
            'Requirement post!',
            style: GoogleFonts.dmSans(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
              fontSize: width * 0.035,
            ),
          ),
        ],
      ),
    );
  }
}
