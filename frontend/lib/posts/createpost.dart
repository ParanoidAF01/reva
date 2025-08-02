import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../notification/notification.dart';

class SharePostScreen extends StatelessWidget {
  const SharePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Container(
      color: const Color(0xFF22252A),
      child: Column(
        children: [
          SizedBox(height: height*0.1,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width*0.05),
            child: Row(
              children: [

                TriangleIcon(size: 20 , color: Colors.white,),
                SizedBox(width: width*0.25,),
                Text("Share post", style: GoogleFonts.dmSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white
                ),)

              ],
            ),
          ),

          const SizedBox(height: 30),

          // Profile Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage('assets/dummyprofile.png'),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Piyush Patyal",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "0/2 Posts",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0262AB), Color(0xFF01345A)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: const Text(
                    "Post",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Prompt Text
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "What do you want to talk\nabout?",
                  style: TextStyle(color: Colors.grey, fontSize: 24),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Bottom Container
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2F343A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildOption(Iconsax.gallery, "Add a photo"),
                _buildOption(Iconsax.video, "Take a video"),
                _buildOption(Iconsax.award, "Celebrate an occasion"),
                _buildOption(Iconsax.document, "Add a document"),
                _buildOption(Iconsax.briefcase, "Share that you’re hiring"),
                _buildOption(Iconsax.people, "Find an expert"),
                _buildOption(Iconsax.chart, "Create a poll"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade300),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade300, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
