import 'package:flutter/material.dart';
import 'package:reva/shared/profile_modal.dart';

class ContactTile extends StatelessWidget {
  final String name;
  final String image;
  final String mobileNumber;
  final String userId;

  const ContactTile({
    super.key,
    required this.name,
    required this.image,
    required this.mobileNumber,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3237),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Profile Image
          CircleAvatar(
            radius: width * 0.06,
            backgroundImage: AssetImage(image),
          ),
          const SizedBox(width: 12),

          // Name & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  mobileNumber,
                  style: const TextStyle(
                    color: Color(0xFFB2B8BD),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Last contacted: 2 days ago',
                  style: TextStyle(
                    color: Color(0xFF8A9299),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Status: Active',
                  style: TextStyle(
                    color: Color(0xFF8A9299),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Notes: Interested in 3BHK, prefers morning calls.',
                  style: TextStyle(
                    color: Color(0xFF8A9299),
                    fontSize: 11.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Custom Gradient Button
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0262AB), Color(0xFF01345A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 24),
                    child: ProfileModal(
                      name: name,
                      image: image,
                      userId: userId,
                      mobileNumber: mobileNumber,
                      isConnection: true,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Text(
                  'View',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
